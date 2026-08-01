-- 가족 메시지.
--
-- `02_MVP_SCOPE` puts the 메시지 탭 in the MVP and `04_SCREEN_SPEC` specifies
-- it; it was simply never built. The PRD prices it: 월 50회 / 이미지 10개 free,
-- unlimited with 안심 케어.
--
-- The quota counts **guardian-sent messages only**. A senior replying to their
-- child is never blocked, whatever the counter says. A launcher for an elderly
-- person that refuses to let them answer their daughter because a monthly
-- allowance ran out would be selling the wrong thing — and the allowance exists
-- to price the guardian's use, not to ration the parent's.

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  senior_profile_id uuid not null
    references public.senior_profiles (id) on delete cascade,
  -- Exactly one of these is set. Which one is what makes a message theirs.
  sender_guardian_id uuid references public.guardian_accounts (id) on delete set null,
  sender_device_id uuid references public.senior_devices (id) on delete set null,
  body text,
  image_url text,
  created_at timestamptz not null default now(),
  constraint one_sender check (
    (sender_guardian_id is null) <> (sender_device_id is null)
  ),
  constraint has_content check (
    coalesce(nullif(trim(body), ''), image_url) is not null
  )
);

create index if not exists messages_conversation_idx
  on public.messages (senior_profile_id, created_at desc);

-- Counting the month's guardian messages is the hot path for the quota, and it
-- runs on every send.
create index if not exists messages_quota_idx
  on public.messages (senior_profile_id, created_at)
  where sender_guardian_id is not null;

alter table public.messages enable row level security;

-- A family conversation: every guardian looking after this parent, and the
-- parent's own phone. Not the sender alone — a sibling has to see what was
-- already said, or they will say it again.
drop policy if exists messages_read on public.messages;
create policy messages_read on public.messages
  for select to authenticated
  using (
    public.guardian_manages(senior_profile_id)
    or public.device_owns(senior_profile_id)
  );

-- ---------------------------------------------------------------------------
-- Quota
-- ---------------------------------------------------------------------------

create or replace function public.family_message_quota(p_senior_profile_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, auth
as $$
declare
  texts int;
  images int;
  unlimited boolean;
begin
  if not (
    public.guardian_manages(p_senior_profile_id)
    or public.device_owns(p_senior_profile_id)
  ) then
    raise exception 'not allowed to manage this profile';
  end if;

  unlimited := public.care_is_active(p_senior_profile_id);

  -- Calendar month, so the number resets on a date the family can predict
  -- rather than on a rolling window nobody can see.
  select
    count(*) filter (where image_url is null),
    count(*) filter (where image_url is not null)
  into texts, images
  from public.messages
  where senior_profile_id = p_senior_profile_id
    and sender_guardian_id is not null
    and created_at >= date_trunc('month', now());

  return jsonb_build_object(
    'unlimited', unlimited,
    'text_used', texts,
    'text_limit', 50,
    'image_used', images,
    'image_limit', 10
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- Sending
-- ---------------------------------------------------------------------------

create or replace function public.send_family_message(
  p_senior_profile_id uuid,
  p_body text default null,
  p_image_url text default null
)
returns public.messages
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  guardian_id uuid;
  device_id uuid;
  used int;
  result public.messages;
begin
  guardian_id := public.current_guardian_account_id();

  select id into device_id
  from public.senior_devices
  where senior_profile_id = p_senior_profile_id
    and auth_user_id = auth.uid()
    and is_active;

  if device_id is null then
    -- A guardian, then — and only one who actually looks after this parent.
    if guardian_id is null or not public.guardian_manages(p_senior_profile_id) then
      raise exception 'not allowed to manage this profile';
    end if;

    -- The quota applies here and nowhere else. The senior's replies fall
    -- through to the insert below without ever being counted.
    if not public.care_is_active(p_senior_profile_id) then
      if p_image_url is not null then
        select count(*) into used from public.messages
        where senior_profile_id = p_senior_profile_id
          and sender_guardian_id is not null
          and image_url is not null
          and created_at >= date_trunc('month', now());
        if used >= 10 then
          raise exception 'image quota reached';
        end if;
      else
        select count(*) into used from public.messages
        where senior_profile_id = p_senior_profile_id
          and sender_guardian_id is not null
          and image_url is null
          and created_at >= date_trunc('month', now());
        if used >= 50 then
          raise exception 'message quota reached';
        end if;
      end if;
    end if;
  else
    -- Sent from the parent's phone. `guardian_id` is cleared so the row records
    -- one sender, even if this auth user somehow also holds a guardian account.
    guardian_id := null;
  end if;

  insert into public.messages
    (senior_profile_id, sender_guardian_id, sender_device_id, body, image_url)
  values (
    p_senior_profile_id,
    guardian_id,
    device_id,
    nullif(trim(coalesce(p_body, '')), ''),
    p_image_url
  )
  returning * into result;

  return result;
end;
$$;

grant execute on function public.family_message_quota(uuid) to authenticated;
grant execute on function public.send_family_message(uuid, text, text) to authenticated;
