-- Phase 5: pairing and recovery.
--
-- Phase 4 linked by the profile's 8-character `customer_code`, typed on the
-- parent's phone. That was a placeholder and this migration replaces it with
-- what `07_PHASE_PLAN` actually specifies — including the direction, which is
-- the opposite way round for the code path:
--
--   경로 A — the guardian creates the profile and texts an install link. The
--     link carries a token; the parent's phone redeems it.
--   경로 B — the parent's phone shows a 4-digit code and the *guardian* types
--     it. The code cannot reveal a phone number, so the guardian supplies the
--     number and the name separately.
--
-- Path A depends on the Play install referrer to survive an install, which
-- only works for installs that went through the store — so path B is not a
-- nicety, it is the required fallback, and the parent's phone must be able to
-- create its own profile with no guardian present.
--
-- Recovery and the family-guardian invite ride on the same table: all four are
-- "a short-lived secret that grants one specific attachment".

-- ---------------------------------------------------------------------------
-- pair_links
-- ---------------------------------------------------------------------------

create table if not exists public.pair_links (
  id uuid primary key default gen_random_uuid(),
  senior_profile_id uuid references public.senior_profiles (id) on delete cascade,
  guardian_account_id uuid references public.guardian_accounts (id) on delete cascade,
  -- Digits only, and read aloud or typed rather than clicked.
  code text not null,
  -- Carried in the install link. Long enough that guessing is pointless,
  -- because unlike the code it has to stay valid for a fortnight.
  token text not null unique,
  mode text not null check (
    mode in (
      'guardian_invites_senior',
      'senior_shares_code',
      'recovery',
      'guardian_invite_family'
    )
  ),
  expires_at timestamptz not null,
  used_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists pair_links_code_idx on public.pair_links (code);
create index if not exists pair_links_profile_idx
  on public.pair_links (senior_profile_id);

-- One pending change of primary guardian per profile, which is why this is a
-- column and not a table: a second request while one is outstanding would ask
-- the senior to approve two things at once.
alter table public.senior_profiles
  add column if not exists pending_primary_guardian_id uuid
    references public.guardian_accounts (id) on delete set null;

-- ---------------------------------------------------------------------------
-- RLS
--
-- Nothing reads this table directly. Every row is created and redeemed through
-- a security-definer function, because redeeming is exactly the case where the
-- caller cannot yet be allowed to see the row they are about to use.
-- ---------------------------------------------------------------------------

alter table public.pair_links enable row level security;

drop policy if exists pair_links_owner_read on public.pair_links;
create policy pair_links_owner_read on public.pair_links
  for select to authenticated
  using (
    guardian_account_id = public.current_guardian_account_id()
    or (senior_profile_id is not null and public.device_owns(senior_profile_id))
  );

-- Phase 4 let a guardian read only their own link row, which was enough while
-- every profile had exactly one guardian. From Phase 5 a family can have
-- several, and 가족 관리 has to list them — a guardian who cannot see who else
-- is looking after their parent cannot tell whether the invite they sent was
-- taken up. The senior's own device can see them too: the list of people
-- answering for you is not a thing to hide from you.
drop policy if exists guardian_senior_links_read on public.guardian_senior_links;
create policy guardian_senior_links_read on public.guardian_senior_links
  for select to authenticated
  using (
    guardian_account_id = public.current_guardian_account_id()
    or public.guardian_manages(senior_profile_id)
    or public.device_owns(senior_profile_id)
  );

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- Digits only: these are read down a phone line to someone who may be writing
-- them on paper, and a letter set would need "as in apple" to be usable.
create or replace function public.generate_pair_code(p_digits int)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  candidate text;
begin
  loop
    candidate := lpad((floor(random() * power(10, p_digits)))::bigint::text, p_digits, '0');
    -- Only live rows have to be distinct. An expired or spent code sharing
    -- these digits can never be redeemed, so it is not a collision.
    exit when not exists (
      select 1 from public.pair_links
      where code = candidate and used_at is null and expires_at > now()
    );
  end loop;
  return candidate;
end;
$$;

create or replace function public.generate_pair_token()
returns text
language sql
security definer
set search_path = public, extensions
as $$
  select encode(gen_random_bytes(16), 'hex');
$$;

-- Finds the one live row for a code, or raises.
--
-- Raises on more than one match rather than picking: two live rows sharing a
-- code should be impossible, and guessing which family a phone joins is not a
-- mistake worth making quietly.
create or replace function public.claim_pair_link(p_code text, p_mode text)
returns public.pair_links
language plpgsql
security definer
set search_path = public
as $$
declare
  found public.pair_links;
  matches int;
begin
  select count(*) into matches
  from public.pair_links
  where code = trim(p_code) and mode = p_mode
    and used_at is null and expires_at > now();

  if matches = 0 then
    raise exception 'no such code';
  elsif matches > 1 then
    raise exception 'ambiguous code';
  end if;

  select * into found
  from public.pair_links
  where code = trim(p_code) and mode = p_mode
    and used_at is null and expires_at > now();

  update public.pair_links set used_at = now() where id = found.id;
  return found;
end;
$$;

-- Attaches an install to a profile and retires whichever phone held it before.
--
-- Extracted from `register_senior_device` because every Phase 5 path ends
-- here: a fresh pairing, a redeemed invite and a recovery all mean "this
-- install is now the live one for this profile".
create or replace function public.attach_senior_device(
  p_senior_profile_id uuid,
  p_install_id text,
  p_device_label text default null,
  p_platform text default null,
  p_os_version text default null
)
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  update public.senior_devices
    set is_active = false
  where senior_profile_id = p_senior_profile_id
    and is_active
    and install_id is distinct from p_install_id;

  insert into public.senior_devices (
    senior_profile_id, auth_user_id, install_id, device_label,
    platform, os_version, last_seen_at, is_active
  )
  values (
    p_senior_profile_id, auth.uid(), p_install_id, p_device_label,
    p_platform, p_os_version, now(), true
  )
  on conflict (install_id) do update
    set senior_profile_id = excluded.senior_profile_id,
        auth_user_id = excluded.auth_user_id,
        device_label = coalesce(excluded.device_label, public.senior_devices.device_label),
        platform = coalesce(excluded.platform, public.senior_devices.platform),
        os_version = coalesce(excluded.os_version, public.senior_devices.os_version),
        last_seen_at = now(),
        is_active = true;
end;
$$;

-- ---------------------------------------------------------------------------
-- 경로 B — the parent's phone shows a code, the guardian types it
-- ---------------------------------------------------------------------------

-- The parent's phone standing on its own, before any guardian exists.
--
-- The name is a placeholder: nobody has asked the senior to type their own
-- name, and the guardian supplies the real one when they claim the code. That
-- is also the only moment a phone number can be attached, since a 4-digit code
-- cannot carry one.
create or replace function public.start_senior_pairing(
  p_install_id text,
  p_device_label text default null,
  p_platform text default null,
  p_os_version text default null
)
returns public.pair_links
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  profile public.senior_profiles;
  link public.pair_links;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  -- A phone that already belongs to a profile is sharing a code for *that*
  -- profile, not making a second one.
  select p.* into profile
  from public.senior_profiles p
  join public.senior_devices d on d.senior_profile_id = p.id
  where d.install_id = p_install_id and d.is_active;

  if profile.id is null then
    insert into public.senior_profiles (display_name, customer_code)
    values ('부모님', public.generate_customer_code())
    returning * into profile;
  end if;

  perform public.attach_senior_device(
    profile.id, p_install_id, p_device_label, p_platform, p_os_version);

  -- Ten minutes: the guardian is expected to be standing next to them or on
  -- the phone with them. A 4-digit code that lives longer is a 4-digit code
  -- worth guessing.
  insert into public.pair_links
    (senior_profile_id, code, token, mode, expires_at)
  values (
    profile.id,
    public.generate_pair_code(4),
    public.generate_pair_token(),
    'senior_shares_code',
    now() + interval '10 minutes'
  )
  returning * into link;

  return link;
end;
$$;

-- The guardian typing what their parent read out, plus the two things the code
-- could not carry: the number to call, and the name the senior will recognise.
create or replace function public.claim_senior_pairing_code(
  p_code text,
  p_display_name text,
  p_phone_number text default null
)
returns public.senior_profiles
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  guardian_id uuid;
  link public.pair_links;
  profile public.senior_profiles;
begin
  guardian_id := public.current_guardian_account_id();
  if guardian_id is null then
    raise exception 'no guardian account for current user';
  end if;

  link := public.claim_pair_link(p_code, 'senior_shares_code');

  update public.senior_profiles
    set display_name = coalesce(nullif(trim(p_display_name), ''), display_name)
  where id = link.senior_profile_id
  returning * into profile;

  insert into public.guardian_senior_links
    (guardian_account_id, senior_profile_id, role, status)
  values (guardian_id, profile.id, 'primary', 'active')
  on conflict (guardian_account_id, senior_profile_id) do update
    set status = 'active';

  if p_phone_number is not null then
    update public.guardian_accounts
      set phone_number = coalesce(phone_number, p_phone_number)
    where id = guardian_id;
  end if;

  return profile;
end;
$$;

-- ---------------------------------------------------------------------------
-- 경로 A — the guardian creates the profile and texts an install link
-- ---------------------------------------------------------------------------

create or replace function public.create_senior_invite(p_display_name text)
returns public.pair_links
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  profile public.senior_profiles;
  link public.pair_links;
begin
  profile := public.create_senior_profile(p_display_name);

  -- Two weeks: the parent has to receive a text, install an app and open it,
  -- possibly with help that arrives at the weekend.
  insert into public.pair_links
    (senior_profile_id, guardian_account_id, code, token, mode, expires_at)
  values (
    profile.id,
    public.current_guardian_account_id(),
    public.generate_pair_code(6),
    public.generate_pair_token(),
    'guardian_invites_senior',
    now() + interval '14 days'
  )
  returning * into link;

  return link;
end;
$$;

-- Redeemed by the parent's phone, either from the install link's token or from
-- the 6-digit code read out when the referrer did not survive the install.
create or replace function public.redeem_senior_invite(
  p_install_id text,
  p_token text default null,
  p_code text default null,
  p_device_label text default null,
  p_platform text default null,
  p_os_version text default null
)
returns public.senior_profiles
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  link public.pair_links;
  profile public.senior_profiles;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  if p_token is not null then
    select * into link
    from public.pair_links
    where token = trim(p_token) and mode = 'guardian_invites_senior'
      and used_at is null and expires_at > now();
    if link.id is null then
      raise exception 'no such code';
    end if;
    update public.pair_links set used_at = now() where id = link.id;
  elsif p_code is not null then
    link := public.claim_pair_link(p_code, 'guardian_invites_senior');
  else
    raise exception 'a token or a code is required';
  end if;

  perform public.attach_senior_device(
    link.senior_profile_id, p_install_id, p_device_label, p_platform, p_os_version);

  select * into profile from public.senior_profiles where id = link.senior_profile_id;
  return profile;
end;
$$;

-- ---------------------------------------------------------------------------
-- Recovery — the parent's phone was reset, replaced, or the app reinstalled
-- ---------------------------------------------------------------------------

create or replace function public.create_recovery_code(p_senior_profile_id uuid)
returns public.pair_links
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  link public.pair_links;
begin
  if not public.guardian_manages(p_senior_profile_id) then
    raise exception 'not allowed to manage this profile';
  end if;

  -- A day: long enough to drive over and sit down with the phone, short
  -- enough that a code left in a text message stops working.
  insert into public.pair_links
    (senior_profile_id, guardian_account_id, code, token, mode, expires_at)
  values (
    p_senior_profile_id,
    public.current_guardian_account_id(),
    public.generate_pair_code(6),
    public.generate_pair_token(),
    'recovery',
    now() + interval '24 hours'
  )
  returning * into link;

  return link;
end;
$$;

-- The whole point of the profile outliving the device: this restores the
-- existing senior rather than creating a second one, so the home screen, the
-- settings and the guardians all come back.
create or replace function public.redeem_recovery_code(
  p_code text,
  p_install_id text,
  p_device_label text default null,
  p_platform text default null,
  p_os_version text default null
)
returns public.senior_profiles
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  link public.pair_links;
  profile public.senior_profiles;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  link := public.claim_pair_link(p_code, 'recovery');

  perform public.attach_senior_device(
    link.senior_profile_id, p_install_id, p_device_label, p_platform, p_os_version);

  select * into profile from public.senior_profiles where id = link.senior_profile_id;
  return profile;
end;
$$;

-- ---------------------------------------------------------------------------
-- Family guardians — free, per the PRD
-- ---------------------------------------------------------------------------

create or replace function public.create_family_invite(p_senior_profile_id uuid)
returns public.pair_links
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  link public.pair_links;
begin
  if not public.guardian_manages(p_senior_profile_id) then
    raise exception 'not allowed to manage this profile';
  end if;

  insert into public.pair_links
    (senior_profile_id, guardian_account_id, code, token, mode, expires_at)
  values (
    p_senior_profile_id,
    public.current_guardian_account_id(),
    public.generate_pair_code(6),
    public.generate_pair_token(),
    'guardian_invite_family',
    now() + interval '7 days'
  )
  returning * into link;

  return link;
end;
$$;

create or replace function public.redeem_family_invite(p_code text)
returns public.senior_profiles
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  guardian_id uuid;
  link public.pair_links;
  profile public.senior_profiles;
begin
  guardian_id := public.current_guardian_account_id();
  if guardian_id is null then
    raise exception 'no guardian account for current user';
  end if;

  link := public.claim_pair_link(p_code, 'guardian_invite_family');

  -- 'family', never 'primary'. Joining by invitation does not take over the
  -- account; that is a separate request the senior has to approve.
  insert into public.guardian_senior_links
    (guardian_account_id, senior_profile_id, role, status)
  values (guardian_id, link.senior_profile_id, 'family', 'active')
  on conflict (guardian_account_id, senior_profile_id) do update
    set status = 'active';

  select * into profile from public.senior_profiles where id = link.senior_profile_id;
  return profile;
end;
$$;

-- ---------------------------------------------------------------------------
-- Changing the primary guardian
--
-- The senior's phone approves it. `07_PHASE_PLAN` makes that a hard
-- requirement, and it is the only check that means anything: everyone else in
-- the list is a guardian, so no arrangement among them can establish which one
-- the senior actually wants answering for them.
-- ---------------------------------------------------------------------------

create or replace function public.request_primary_guardian(p_senior_profile_id uuid)
returns public.senior_profiles
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  guardian_id uuid;
  profile public.senior_profiles;
begin
  guardian_id := public.current_guardian_account_id();
  if not public.guardian_manages(p_senior_profile_id) then
    raise exception 'not allowed to manage this profile';
  end if;

  if exists (
    select 1 from public.guardian_senior_links
    where senior_profile_id = p_senior_profile_id
      and guardian_account_id = guardian_id
      and role = 'primary' and status = 'active'
  ) then
    raise exception 'already the primary guardian';
  end if;

  update public.senior_profiles
    set pending_primary_guardian_id = guardian_id
  where id = p_senior_profile_id
  returning * into profile;

  return profile;
end;
$$;

create or replace function public.resolve_primary_guardian(
  p_senior_profile_id uuid,
  p_approve boolean
)
returns public.senior_profiles
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  pending uuid;
  profile public.senior_profiles;
begin
  -- Only the phone in the senior's hand. A guardian approving their own
  -- request would make the approval ceremonial.
  if not public.device_owns(p_senior_profile_id) then
    raise exception 'only the senior device can answer this';
  end if;

  select pending_primary_guardian_id into pending
  from public.senior_profiles where id = p_senior_profile_id;

  if pending is null then
    raise exception 'nothing to answer';
  end if;

  if p_approve then
    update public.guardian_senior_links
      set role = 'family'
    where senior_profile_id = p_senior_profile_id and role = 'primary';

    update public.guardian_senior_links
      set role = 'primary', status = 'active'
    where senior_profile_id = p_senior_profile_id
      and guardian_account_id = pending;
  end if;

  update public.senior_profiles
    set pending_primary_guardian_id = null
  where id = p_senior_profile_id
  returning * into profile;

  return profile;
end;
$$;

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

grant execute on function public.start_senior_pairing(text, text, text, text) to authenticated;
grant execute on function public.claim_senior_pairing_code(text, text, text) to authenticated;
grant execute on function public.create_senior_invite(text) to authenticated;
grant execute on function public.redeem_senior_invite(text, text, text, text, text, text) to authenticated;
grant execute on function public.create_recovery_code(uuid) to authenticated;
grant execute on function public.redeem_recovery_code(text, text, text, text, text) to authenticated;
grant execute on function public.create_family_invite(uuid) to authenticated;
grant execute on function public.redeem_family_invite(text) to authenticated;
grant execute on function public.request_primary_guardian(uuid) to authenticated;
grant execute on function public.resolve_primary_guardian(uuid, boolean) to authenticated;

revoke execute on function public.generate_pair_code(int) from anon, authenticated;
revoke execute on function public.generate_pair_token() from anon, authenticated;
revoke execute on function public.claim_pair_link(text, text) from anon, authenticated;
revoke execute on function public.attach_senior_device(uuid, text, text, text, text)
  from anon, authenticated;
