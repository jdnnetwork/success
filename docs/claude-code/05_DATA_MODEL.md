# Data Model

Use Supabase PostgreSQL. Names below are recommended.

## guardian_accounts
보호자 계정.

Fields:
- id uuid primary key
- auth_user_id uuid unique not null
- display_name text
- phone_number text
- email text
- created_at timestamptz
- updated_at timestamptz

## senior_profiles
부모님 1명 단위의 영속 프로필.

Fields:
- id uuid primary key
- display_name text
- age_band text
- customer_code text unique
- screen_mode text
- font_size text
- paid_consent_status text
- created_at timestamptz
- updated_at timestamptz

Notes:
- 앱 삭제, 재설치, 폰 교체가 있어도 이 프로필은 유지된다.
- 디바이스 ID가 아니라 이 테이블이 피보호자 데이터의 기준이다.

## senior_devices
현재 설치된 부모님 폰.

Fields:
- id uuid primary key
- senior_profile_id uuid references senior_profiles(id)
- install_id text unique
- device_label text
- platform text
- os_version text
- push_token text
- last_seen_at timestamptz
- permission_status jsonb
- is_active boolean
- created_at timestamptz
- updated_at timestamptz

Notes:
- 새 기기가 연결되면 기존 active device는 false가 된다.

## guardian_senior_links
보호자와 피보호자 연결 관계.

Fields:
- id uuid primary key
- guardian_account_id uuid references guardian_accounts(id)
- senior_profile_id uuid references senior_profiles(id)
- role text
- status text
- created_at timestamptz
- updated_at timestamptz

role:
- primary
- family

status:
- active
- pending
- removed

## home_apps
피보호자 런처 버튼 구성.

Fields:
- id uuid primary key
- senior_profile_id uuid references senior_profiles(id)
- app_type text
- package_name text
- label text
- icon_key text
- button_color text
- sort_order int
- is_default boolean
- created_at timestamptz
- updated_at timestamptz

app_type:
- system_app
- installed_app
- setting_shortcut
- family_contact
- sos

## messages
가족 메시지.

Fields:
- id uuid primary key
- senior_profile_id uuid references senior_profiles(id)
- sender_guardian_id uuid null
- sender_device_id uuid null
- body text
- image_url text null
- created_at timestamptz

## recovery_links
부모님 폰 다시 연결.

Fields:
- id uuid primary key
- senior_profile_id uuid references senior_profiles(id)
- requested_by_guardian_id uuid references guardian_accounts(id)
- token text unique
- code text
- expires_at timestamptz
- used_at timestamptz null
- status text
- created_at timestamptz

status:
- pending
- used
- expired
- revoked

## pair_links
가족 연결용 코드/초대 링크.

Fields:
- id uuid primary key
- senior_profile_id uuid null
- guardian_account_id uuid null
- code text
- token text
- mode text
- expires_at timestamptz
- used_at timestamptz null
- created_at timestamptz

mode:
- guardian_invites_senior
- senior_shares_code
- recovery
- guardian_invite_family

## subscriptions
유료 상태.

Fields:
- id uuid primary key
- guardian_account_id uuid references guardian_accounts(id)
- plan text
- status text
- started_at timestamptz
- canceled_at timestamptz null
- refunded_at timestamptz null

plan:
- care
- family

status:
- active
- pending_senior_consent
- refunded
- canceled

## alerts
보호자 알림.

Fields:
- id uuid primary key
- senior_profile_id uuid references senior_profiles(id)
- type text
- title text
- body text
- metadata jsonb
- created_at timestamptz
- read_at timestamptz null

