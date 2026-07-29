-- Phase 4: Supabase integration — core schema.
--
-- Scope is exactly what `07_PHASE_PLAN_FOR_CLAUDE_CODE.md` lists for Phase 4:
-- guardian accounts, senior profiles, senior devices, the link between them,
-- and the home-app rows that sync between a guardian and the parent's phone.
-- `pair_links` / `recovery_links` (Phase 5) and `subscriptions` (Phase 6) are
-- deliberately absent — each phase is meant to land on its own.
--
-- Two kinds of caller reach these tables:
--   * a guardian, signed in with a real account (email today, OAuth later);
--   * the parent's phone, signed in anonymously — it has no account and the
--     senior is never asked to make one. `senior_devices.auth_user_id` is what
--     ties that anonymous user to the profile it is allowed to touch.
-- Every table is therefore reachable only through RLS keyed on one of those.

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table if not exists public.guardian_accounts (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null unique references auth.users (id) on delete cascade,
  display_name text,
  phone_number text,
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.senior_profiles (
  id uuid primary key default gen_random_uuid(),
  display_name text not null,
  age_band text,
  -- Handed to the guardian so a reinstalled phone can find this profile again.
  -- Phase 5 layers the 4-digit pairing code and invite links on top of it.
  customer_code text not null unique,
  -- Both nullable, and neither defaulted: null means "nobody has chosen yet".
  -- A profile created by a guardian before the parent's phone connects has no
  -- opinion about either, and defaulting font_size to 'normal' would let that
  -- silence overwrite a senior who had already set 아주 크게.
  screen_mode text check (screen_mode in ('easy', 'detailed')),
  font_size text check (font_size in ('normal', 'large', 'extraLarge')),
  paid_consent_status text not null default 'none'
    check (paid_consent_status in ('none', 'pending', 'granted', 'refused')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- The parent's phone. A profile outlives any device: reinstalling or replacing
-- the phone adds a row here, it does not create a second senior.
create table if not exists public.senior_devices (
  id uuid primary key default gen_random_uuid(),
  senior_profile_id uuid not null
    references public.senior_profiles (id) on delete cascade,
  -- The anonymous auth user this install signed in as. Nullable so a guardian
  -- can see a device row that was written before the device authenticated.
  auth_user_id uuid unique references auth.users (id) on delete set null,
  install_id text not null unique,
  device_label text,
  platform text,
  os_version text,
  push_token text,
  last_seen_at timestamptz,
  permission_status jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists senior_devices_profile_idx
  on public.senior_devices (senior_profile_id);

-- Only one install may be the live one for a profile; connecting a new phone
-- flips the old row to inactive rather than deleting its history.
create unique index if not exists senior_devices_one_active_per_profile
  on public.senior_devices (senior_profile_id)
  where is_active;

create table if not exists public.guardian_senior_links (
  id uuid primary key default gen_random_uuid(),
  guardian_account_id uuid not null
    references public.guardian_accounts (id) on delete cascade,
  senior_profile_id uuid not null
    references public.senior_profiles (id) on delete cascade,
  role text not null default 'primary' check (role in ('primary', 'family')),
  status text not null default 'active'
    check (status in ('active', 'pending', 'removed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (guardian_account_id, senior_profile_id)
);

create index if not exists guardian_senior_links_profile_idx
  on public.guardian_senior_links (senior_profile_id);

-- The launcher's home buttons. `client_id`, `label`, `icon_key` and
-- `button_color` are the server side of the app's `LauncherApp`; `client_id` is
-- the id the launcher already uses, so renaming or recolouring a button on
-- either phone lands on the same row instead of creating a new button.
create table if not exists public.home_apps (
  id uuid primary key default gen_random_uuid(),
  senior_profile_id uuid not null
    references public.senior_profiles (id) on delete cascade,
  client_id text not null,
  app_type text not null default 'system_app'
    check (app_type in (
      'system_app', 'installed_app', 'setting_shortcut', 'family_contact', 'sos'
    )),
  package_name text,
  label text not null,
  icon_key text not null,
  button_color text,
  sort_order int not null default 0,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (senior_profile_id, client_id)
);

create index if not exists home_apps_profile_order_idx
  on public.home_apps (senior_profile_id, sort_order);

-- ---------------------------------------------------------------------------
-- updated_at
-- ---------------------------------------------------------------------------

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

do $$
declare
  t text;
begin
  foreach t in array array[
    'guardian_accounts', 'senior_profiles', 'senior_devices',
    'guardian_senior_links', 'home_apps'
  ] loop
    execute format('drop trigger if exists touch_updated_at on public.%I', t);
    execute format(
      'create trigger touch_updated_at before update on public.%I
         for each row execute function public.touch_updated_at()', t);
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- Access helpers
--
-- security definer so a policy on one table can consult another without
-- needing the caller to hold read access there — otherwise the link check and
-- the profile policy would each require the other and recurse.
-- ---------------------------------------------------------------------------

create or replace function public.current_guardian_account_id()
returns uuid
language sql
stable
security definer
set search_path = public, auth
as $$
  select id from public.guardian_accounts where auth_user_id = auth.uid();
$$;

create or replace function public.guardian_manages(profile uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select exists (
    select 1
    from public.guardian_senior_links l
    join public.guardian_accounts g on g.id = l.guardian_account_id
    where l.senior_profile_id = profile
      and l.status = 'active'
      and g.auth_user_id = auth.uid()
  );
$$;

create or replace function public.device_owns(profile uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select exists (
    select 1
    from public.senior_devices d
    where d.senior_profile_id = profile
      and d.auth_user_id = auth.uid()
      and d.is_active
  );
$$;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.guardian_accounts enable row level security;
alter table public.senior_profiles enable row level security;
alter table public.senior_devices enable row level security;
alter table public.guardian_senior_links enable row level security;
alter table public.home_apps enable row level security;

drop policy if exists guardian_accounts_own on public.guardian_accounts;
create policy guardian_accounts_own on public.guardian_accounts
  for all to authenticated
  using (auth_user_id = auth.uid())
  with check (auth_user_id = auth.uid());

drop policy if exists senior_profiles_read on public.senior_profiles;
create policy senior_profiles_read on public.senior_profiles
  for select to authenticated
  using (public.guardian_manages(id) or public.device_owns(id));

-- Creating a profile is open to any signed-in caller because the guardian who
-- creates it cannot yet be linked to it. `create_senior_profile` writes the
-- link in the same transaction, which is what makes the row reachable again.
drop policy if exists senior_profiles_insert on public.senior_profiles;
create policy senior_profiles_insert on public.senior_profiles
  for insert to authenticated
  with check (true);

drop policy if exists senior_profiles_update on public.senior_profiles;
create policy senior_profiles_update on public.senior_profiles
  for update to authenticated
  using (public.guardian_manages(id) or public.device_owns(id))
  with check (public.guardian_manages(id) or public.device_owns(id));

drop policy if exists senior_devices_read on public.senior_devices;
create policy senior_devices_read on public.senior_devices
  for select to authenticated
  using (
    auth_user_id = auth.uid() or public.guardian_manages(senior_profile_id)
  );

-- A device may only write its own row. Retiring the *previous* phone touches a
-- row belonging to a different anonymous user, so that path goes through
-- `register_senior_device` rather than a policy.
drop policy if exists senior_devices_write_own on public.senior_devices;
create policy senior_devices_write_own on public.senior_devices
  for update to authenticated
  using (auth_user_id = auth.uid())
  with check (auth_user_id = auth.uid());

drop policy if exists guardian_senior_links_read on public.guardian_senior_links;
create policy guardian_senior_links_read on public.guardian_senior_links
  for select to authenticated
  using (
    guardian_account_id = public.current_guardian_account_id()
    or public.device_owns(senior_profile_id)
  );

drop policy if exists guardian_senior_links_write on public.guardian_senior_links;
create policy guardian_senior_links_write on public.guardian_senior_links
  for update to authenticated
  using (guardian_account_id = public.current_guardian_account_id())
  with check (guardian_account_id = public.current_guardian_account_id());

drop policy if exists home_apps_all on public.home_apps;
create policy home_apps_all on public.home_apps
  for all to authenticated
  using (
    public.guardian_manages(senior_profile_id)
    or public.device_owns(senior_profile_id)
  )
  with check (
    public.guardian_manages(senior_profile_id)
    or public.device_owns(senior_profile_id)
  );

-- ---------------------------------------------------------------------------
-- RPCs
-- ---------------------------------------------------------------------------

-- The guardian's own row, created on first sign-in. Idempotent: signing in
-- again updates the profile fields rather than failing on the unique index.
create or replace function public.ensure_guardian_account(
  p_display_name text default null,
  p_phone_number text default null
)
returns public.guardian_accounts
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  result public.guardian_accounts;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  insert into public.guardian_accounts (auth_user_id, display_name, phone_number, email)
  values (
    auth.uid(),
    p_display_name,
    p_phone_number,
    (select email from auth.users where id = auth.uid())
  )
  on conflict (auth_user_id) do update
    set display_name = coalesce(excluded.display_name, public.guardian_accounts.display_name),
        phone_number = coalesce(excluded.phone_number, public.guardian_accounts.phone_number),
        email = coalesce(excluded.email, public.guardian_accounts.email)
  returning * into result;

  return result;
end;
$$;

-- Unambiguous alphabet: no O/0, I/1, so a code read aloud over the phone or
-- copied off a screen cannot land on the wrong profile.
create or replace function public.generate_customer_code()
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  alphabet constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  candidate text;
  i int;
begin
  loop
    candidate := '';
    for i in 1..8 loop
      candidate := candidate || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
    end loop;
    exit when not exists (
      select 1 from public.senior_profiles where customer_code = candidate
    );
  end loop;
  return candidate;
end;
$$;

-- Creates the parent's profile and the guardian's link to it together. Split
-- into two calls a failure between them would leave a profile nobody can read.
create or replace function public.create_senior_profile(
  p_display_name text,
  p_age_band text default null
)
returns public.senior_profiles
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  guardian_id uuid;
  result public.senior_profiles;
begin
  guardian_id := public.current_guardian_account_id();
  if guardian_id is null then
    raise exception 'no guardian account for current user';
  end if;

  insert into public.senior_profiles (display_name, age_band, customer_code)
  values (p_display_name, p_age_band, public.generate_customer_code())
  returning * into result;

  insert into public.guardian_senior_links
    (guardian_account_id, senior_profile_id, role, status)
  values (guardian_id, result.id, 'primary', 'active');

  return result;
end;
$$;

-- The parent's phone claiming its profile, by the code the guardian read to
-- them. Retiring the previous install is part of the same statement, so a
-- profile never has two phones both believing they are live.
create or replace function public.register_senior_device(
  p_customer_code text,
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
  profile public.senior_profiles;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  select * into profile
  from public.senior_profiles
  where customer_code = upper(trim(p_customer_code));

  if profile.id is null then
    raise exception 'unknown customer code';
  end if;

  update public.senior_devices
    set is_active = false
  where senior_profile_id = profile.id
    and is_active
    and install_id is distinct from p_install_id;

  insert into public.senior_devices (
    senior_profile_id, auth_user_id, install_id, device_label,
    platform, os_version, last_seen_at, is_active
  )
  values (
    profile.id, auth.uid(), p_install_id, p_device_label,
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

  return profile;
end;
$$;

-- Replaces the whole button list in one statement.
--
-- The launcher edits order, labels and colours as a set, and a partial write
-- would leave the parent looking at a home screen that is half old and half
-- new. Rows absent from the payload are removed; rows still present are updated
-- in place, so a button keeps its row id across a rename or a reorder.
create or replace function public.replace_home_apps(
  p_senior_profile_id uuid,
  p_apps jsonb
)
returns setof public.home_apps
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if not (
    public.guardian_manages(p_senior_profile_id)
    or public.device_owns(p_senior_profile_id)
  ) then
    raise exception 'not allowed to manage this profile';
  end if;

  -- `not exists` rather than `not in`: a payload row with a missing client_id
  -- would turn `not in` null and silently delete nothing.
  delete from public.home_apps h
  where h.senior_profile_id = p_senior_profile_id
    and not exists (
      select 1
      from jsonb_array_elements(p_apps) e
      where e.value ->> 'client_id' = h.client_id
    );

  insert into public.home_apps (
    senior_profile_id, client_id, app_type, package_name,
    label, icon_key, button_color, sort_order, is_default
  )
  select
    p_senior_profile_id,
    app ->> 'client_id',
    coalesce(app ->> 'app_type', 'system_app'),
    app ->> 'package_name',
    app ->> 'label',
    app ->> 'icon_key',
    app ->> 'button_color',
    coalesce((app ->> 'sort_order')::int, ordinality::int - 1),
    coalesce((app ->> 'is_default')::boolean, false)
  from jsonb_array_elements(p_apps) with ordinality as t(app, ordinality)
  on conflict (senior_profile_id, client_id) do update
    set app_type = excluded.app_type,
        package_name = excluded.package_name,
        label = excluded.label,
        icon_key = excluded.icon_key,
        button_color = excluded.button_color,
        sort_order = excluded.sort_order,
        is_default = excluded.is_default;

  return query
    select * from public.home_apps
    where senior_profile_id = p_senior_profile_id
    order by sort_order;
end;
$$;

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

grant execute on function public.ensure_guardian_account(text, text) to authenticated;
grant execute on function public.create_senior_profile(text, text) to authenticated;
grant execute on function public.register_senior_device(text, text, text, text, text) to authenticated;
grant execute on function public.replace_home_apps(uuid, jsonb) to authenticated;

revoke execute on function public.generate_customer_code() from anon, authenticated;
