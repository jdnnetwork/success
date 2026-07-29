# Phase 4 — Supabase Integration

What was built, and the decisions that are not obvious from the diff.

`07_PHASE_PLAN_FOR_CLAUDE_CODE.md` asks Phase 4 for: schema migration, guardian
auth, repositories, senior profile creation, senior device creation, and
guardian-senior linking — accepted when a guardian can log in, a senior profile
can be linked, and home app settings sync when the parent's phone is online.

## Two kinds of caller, one of whom has no account

The guardian signs in. The senior never does — `06_PERMISSION_AND_POLICY` is
built around asking them for as little as possible, and an account is more than
a launcher should need.

So the parent's phone signs in **anonymously** and `senior_devices.auth_user_id`
records which anonymous user this install is. Every RLS policy on the senior
side keys off that column through `device_owns(profile)`; the guardian side keys
off `guardian_manages(profile)`. Both helpers are `security definer`, because a
policy on `senior_profiles` that consults `guardian_senior_links` and a policy
on `guardian_senior_links` that consults `senior_profiles` would recurse.

This is the one place the schema departs from `05_DATA_MODEL` on purpose.
Turning anonymous sign-ins off on the project breaks every senior device.

## Writes that must not be splittable go through RPCs

Three operations cannot be a plain table write:

- **`create_senior_profile`** — a profile with no link is a row that RLS makes
  unreadable to the guardian who just created it. Profile and link are inserted
  in one function.
- **`register_senior_device`** — retiring the previous phone touches a row owned
  by a *different* anonymous user, which no policy can allow without also
  allowing one senior's phone to write another's.
- **`replace_home_apps`** — the launcher edits order, labels and colours as one
  arrangement. A per-button patch would let a phone that missed one call end up
  with a home screen neither side chose.

A partial unique index (`senior_devices_one_active_per_profile`) backs the
second one, so "one live phone per profile" is enforced by the database rather
than only by the function that maintains it.

## Null means nobody has chosen

`senior_profiles.screen_mode` and `font_size` are both nullable with no default.

A guardian creates the profile before their parent's phone connects, so the row
genuinely has no opinion about either. Defaulting `font_size` to `'normal'`
would make that silence indistinguishable from a choice, and pulling it down
would shrink the text of a senior who had already set 아주 크게. `SeniorProfile`
mirrors this with `FontSize?`, and `applyTo` falls back to what the phone
already had.

## Sync is one-directional at a time, and never blocking

`SeniorSettingsSync.push` runs after every local write, unawaited. Disk is the
source of truth; the server is a copy. An edit has to land at full speed on a
phone with no signal, so `push` swallows its own failures and returns a boolean
nobody shows on screen. `SeniorSettingsController.pendingSync` exists so tests
can wait for it.

`pull` runs once, on connect, and treats an empty server list as "nothing to
say" rather than "no buttons" — a profile that has never been pushed to reads as
zero rows, and adopting that literally would leave the senior with a blank home
screen. On connect the phone pulls first and only pushes if the pull found
nothing: a guardian who tidied the home screen while waiting holds the newer
intent.

## No backend is still a supported configuration

`SupabaseConfig.isConfigured` is false without `--dart-define` keys, and every
repository provider resolves to an `InMemory…` twin. This is not a test
convenience — Phases 0-3 were built and accepted with no backend, and this app
is the phone's launcher, so refusing to draw the home screen because a build
flag was forgotten is a worse failure than running offline.

The in-memory twins enforce the same rules the database does (an unlinked
guardian sees nothing, one install is live per profile, a wrong code is
refused), so a widget test exercises the branches the live repository would.

## What was deliberately not built

- **Kakao / Google sign-in.** Neither has an OAuth client on the project and
  only the repo owner can add one. `GuardianStartScreen` keeps both buttons and
  its argument for them; with a project attached they now explain that the
  provider is being prepared and offer the email route. Undoing that screen's
  "sign-up and sign-in are one action" decision was not in scope.
- **The 4-digit pairing code, the install link, recovery, primary-guardian
  change.** All Phase 5. Phase 4 links by the profile's 8-character
  `customer_code`, and `SeniorLinkController.connect` takes a code rather than a
  link precisely so the Phase 5 flows can feed it.
- **`messages`, `alerts`, `subscriptions`, `pair_links`, `recovery_links`.**
  Phase 5 and Phase 6 tables. The phase plan asks that each phase land on its
  own.
- **Realtime.** Sync is on write and on connect. A guardian's edit reaches the
  parent's phone the next time that phone pulls, which today means on connect.
  Push delivery is Phase 6's 5-minute background sync interface.

## Verifying

`tool/verify_supabase_phase4.py` runs the acceptance list against the live
project with real accounts — including the RLS denials, which are the part a
Dart test cannot prove — and deletes everything it created.

```bash
SSL_CERT_FILE=/root/.ccr/ca-bundle.crt python3 tool/verify_supabase_phase4.py
```

The CA bundle and a non-default `User-Agent` are both required; the agent proxy
403s Python's default one.
