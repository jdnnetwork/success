-- Phase 6: paid features.
--
-- Three rules from `06_PERMISSION_AND_POLICY` shape all of this, and none of
-- them is a detail:
--
--   * 안심 케어 does not turn on when it is paid for. It turns on when the
--     senior agrees, on their own phone, afterwards.
--   * A refusal refunds. It does not retry, nag, or degrade — and it leaves
--     every free feature exactly as it was.
--   * The location feature is 5분 주기 위치 확인 and must never be described as
--     real-time tracking, because how it is described is what the senior is
--     agreeing to.
--
-- No money moves here. Google Play Billing is native, needs a store listing,
-- and cannot be built or verified from this environment; `subscriptions` is the
-- state a real purchase would drive, and `start_care_subscription` is where a
-- verified purchase token will be checked.

-- ---------------------------------------------------------------------------
-- subscriptions
-- ---------------------------------------------------------------------------

create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  guardian_account_id uuid not null
    references public.guardian_accounts (id) on delete cascade,
  -- Null for 'family': that plan is about how many parents this guardian may
  -- manage, so it belongs to the account rather than to any one parent.
  -- Required for 'care', which is bought for a particular person and needs
  -- that particular person's consent.
  senior_profile_id uuid references public.senior_profiles (id) on delete cascade,
  plan text not null check (plan in ('care', 'family')),
  status text not null check (
    status in ('active', 'pending_senior_consent', 'refunded', 'canceled')
  ),
  started_at timestamptz not null default now(),
  canceled_at timestamptz,
  refunded_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint care_needs_a_senior check (
    plan <> 'care' or senior_profile_id is not null
  )
);

create index if not exists subscriptions_guardian_idx
  on public.subscriptions (guardian_account_id);
create index if not exists subscriptions_profile_idx
  on public.subscriptions (senior_profile_id);

-- One live 안심 케어 per parent, and one live family plan per guardian. Without
-- this a double tap on 결제하기 buys twice.
create unique index if not exists subscriptions_one_live_care
  on public.subscriptions (senior_profile_id)
  where plan = 'care' and status in ('active', 'pending_senior_consent');

create unique index if not exists subscriptions_one_live_family
  on public.subscriptions (guardian_account_id)
  where plan = 'family' and status = 'active';

drop trigger if exists touch_updated_at on public.subscriptions;
create trigger touch_updated_at before update on public.subscriptions
  for each row execute function public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- alerts
--
-- The guardian's side of anything that happened while they were not looking.
-- Phase 6 writes one kind — the senior refused — and the watcher interfaces
-- will write the rest.
-- ---------------------------------------------------------------------------

create table if not exists public.alerts (
  id uuid primary key default gen_random_uuid(),
  senior_profile_id uuid not null
    references public.senior_profiles (id) on delete cascade,
  type text not null check (
    type in (
      'care_consent_refused',
      'care_consent_granted',
      'location_permission_refused',
      'unknown_contact_call',
      'app_installed'
    )
  ),
  title text not null,
  body text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  read_at timestamptz
);

create index if not exists alerts_profile_idx
  on public.alerts (senior_profile_id, created_at desc);

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.subscriptions enable row level security;
alter table public.alerts enable row level security;

drop policy if exists subscriptions_read on public.subscriptions;
create policy subscriptions_read on public.subscriptions
  for select to authenticated
  using (
    guardian_account_id = public.current_guardian_account_id()
    -- The senior's phone can see that 안심 케어 is waiting on them. Being asked
    -- to consent to something you are not allowed to look at is not consent.
    or (senior_profile_id is not null and public.device_owns(senior_profile_id))
  );

drop policy if exists alerts_read on public.alerts;
create policy alerts_read on public.alerts
  for select to authenticated
  using (public.guardian_manages(senior_profile_id));

drop policy if exists alerts_mark_read on public.alerts;
create policy alerts_mark_read on public.alerts
  for update to authenticated
  using (public.guardian_manages(senior_profile_id))
  with check (public.guardian_manages(senior_profile_id));

-- ---------------------------------------------------------------------------
-- The family plan gate
-- ---------------------------------------------------------------------------

create or replace function public.has_family_plan()
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select exists (
    select 1 from public.subscriptions
    where guardian_account_id = public.current_guardian_account_id()
      and plan = 'family' and status = 'active'
  );
$$;

-- Raises when the guardian is about to take on a second parent without the
-- family plan.
--
-- Counted over active links rather than over profiles they created: a sibling
-- who was invited to help with one parent has one parent, however that link
-- came about.
create or replace function public.assert_can_add_senior()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  existing int;
begin
  select count(*) into existing
  from public.guardian_senior_links
  where guardian_account_id = public.current_guardian_account_id()
    and status = 'active';

  if existing >= 1 and not public.has_family_plan() then
    raise exception 'family plan required';
  end if;
end;
$$;

-- The three paths that attach a guardian to a parent all go through the gate.
-- Recovery and the family invite deliberately do not: recovery is the same
-- parent, and a sibling accepting an invitation is the free feature the PRD
-- says it is.
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

  perform public.assert_can_add_senior();

  insert into public.senior_profiles (display_name, age_band, customer_code)
  values (p_display_name, p_age_band, public.generate_customer_code())
  returning * into result;

  insert into public.guardian_senior_links
    (guardian_account_id, senior_profile_id, role, status)
  values (guardian_id, result.id, 'primary', 'active');

  return result;
end;
$$;

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

  perform public.assert_can_add_senior();

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
-- 안심 케어: paid, then consented to, in that order
-- ---------------------------------------------------------------------------

create or replace function public.start_family_plan()
returns public.subscriptions
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  guardian_id uuid;
  result public.subscriptions;
begin
  guardian_id := public.current_guardian_account_id();
  if guardian_id is null then
    raise exception 'no guardian account for current user';
  end if;

  -- No senior consent: this plan changes how many parents the guardian may
  -- manage, and each of those parents still has to pair with them separately.
  insert into public.subscriptions (guardian_account_id, plan, status)
  values (guardian_id, 'family', 'active')
  returning * into result;

  return result;
end;
$$;

-- Step 1 of the paid flow. Note the status: paying does not switch anything on.
create or replace function public.start_care_subscription(p_senior_profile_id uuid)
returns public.subscriptions
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  result public.subscriptions;
begin
  if not public.guardian_manages(p_senior_profile_id) then
    raise exception 'not allowed to manage this profile';
  end if;

  insert into public.subscriptions
    (guardian_account_id, senior_profile_id, plan, status)
  values (
    public.current_guardian_account_id(),
    p_senior_profile_id,
    'care',
    'pending_senior_consent'
  )
  returning * into result;

  -- The senior's phone reads this to know it has been asked.
  update public.senior_profiles
    set paid_consent_status = 'pending'
  where id = p_senior_profile_id;

  return result;
end;
$$;

-- Steps 3 and 4, answered on the senior's phone.
--
-- A refusal is not a failure to handle later: it refunds immediately, tells the
-- guardian, and leaves the free features untouched. Nothing here disables
-- anything a senior was already using.
create or replace function public.resolve_care_consent(
  p_senior_profile_id uuid,
  p_approve boolean
)
returns public.senior_profiles
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  profile public.senior_profiles;
begin
  if not public.device_owns(p_senior_profile_id) then
    raise exception 'only the senior device can answer this';
  end if;

  if not exists (
    select 1 from public.subscriptions
    where senior_profile_id = p_senior_profile_id
      and plan = 'care' and status = 'pending_senior_consent'
  ) then
    raise exception 'nothing to answer';
  end if;

  update public.subscriptions
    set status = case when p_approve then 'active' else 'refunded' end,
        refunded_at = case when p_approve then null else now() end
  where senior_profile_id = p_senior_profile_id
    and plan = 'care' and status = 'pending_senior_consent';

  update public.senior_profiles
    set paid_consent_status = case when p_approve then 'granted' else 'refused' end
  where id = p_senior_profile_id
  returning * into profile;

  insert into public.alerts (senior_profile_id, type, title, body)
  values (
    p_senior_profile_id,
    case when p_approve then 'care_consent_granted' else 'care_consent_refused' end,
    case
      when p_approve then profile.display_name || '님이 안심 케어를 허락하셨어요'
      else profile.display_name || '님이 안심 케어를 원하지 않으셨어요'
    end,
    case
      when p_approve then '이제 기기 상태와 위치 확인을 켤 수 있어요.'
      else '결제는 환불 처리되었습니다. 무료 기능은 그대로 쓰실 수 있어요.'
    end
  );

  return profile;
end;
$$;

-- Whether the paid features may run for this parent at all.
--
-- Both halves are required, and the consent half is the one that matters: a
-- paid subscription with no consent must behave exactly like no subscription.
create or replace function public.care_is_active(p_senior_profile_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select exists (
    select 1
    from public.subscriptions s
    join public.senior_profiles p on p.id = s.senior_profile_id
    where s.senior_profile_id = p_senior_profile_id
      and s.plan = 'care'
      and s.status = 'active'
      and p.paid_consent_status = 'granted'
  );
$$;

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

grant execute on function public.start_family_plan() to authenticated;
grant execute on function public.start_care_subscription(uuid) to authenticated;
grant execute on function public.resolve_care_consent(uuid, boolean) to authenticated;
grant execute on function public.care_is_active(uuid) to authenticated;
grant execute on function public.has_family_plan() to authenticated;

revoke execute on function public.assert_can_add_senior() from anon, authenticated;
