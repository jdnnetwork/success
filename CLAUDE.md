# 잘보이네 — Flutter senior launcher

## Environment

Remote sessions have no Flutter SDK. `.claude/hooks/session-start.sh` installs
the revision pinned in `.metadata` (currently 3.38.9 / Dart 3.10.8) and puts it
on `PATH`. It runs automatically at session start — roughly 1m30s cold, and it
skips the download when the SDK is already correct.

If `flutter` is somehow missing, run the hook by hand:

```bash
CLAUDE_CODE_REMOTE=true ./.claude/hooks/session-start.sh
```

Commands:

```bash
flutter analyze          # currently clean
flutter test             # currently 158 tests, all passing
```

The SDK unpacks as a root-owned git checkout, so `git config --global --add
safe.directory /opt/flutter` is required or every flutter command aborts on
dubious ownership. The hook already does this.

## Skills

The Superpowers skills library is vendored at `.claude/skills/` because
`/plugin install` cannot be run from a remote session. The plan documents in
`docs/superpowers/plans/` name `subagent-driven-development` and
`executing-plans` as the required sub-skills for implementing them
task-by-task.

## Where the project stands

`docs/claude-code/07_PHASE_PLAN_FOR_CLAUDE_CODE.md` is the phase plan, and it
asks that each phase be implemented, reviewed, and tested on its own rather
than all at once.

- **Phase 0 (project setup)** — done. Riverpod, go_router, feature-first layout.
- **Phase 1 (senior launcher)** — done, then reworked: the role-split screen was
  replaced by the splash in
  `docs/superpowers/specs/2026-07-29-splash-and-guardian-entry-design.md`. The
  phone inside the illustration is the start control; there is no 시작하기
  button, and removing it again would undo a deliberate decision.
- **Phase 2 (local settings)** — done. Settings persist through
  `SharedPreferencesSeniorSettingsRepository`; 설정 → 앱 설정하기 reorders,
  renames, recolours and removes buttons, 글씨 크기 조절하기 picks the text size.
  Both homes draw from the saved list rather than the constant defaults.
- **Phase 3 (guardian dashboard)** — done as UI only. Four tabs, navigable with
  no backend, all data mocked.
- **Phase 4 (Supabase)** — done. Schema, RLS and RPCs are applied to the live
  project; guardian email sign-in, senior profile creation, device registration
  and two-way home-app sync all work. See `## Supabase` below.
- **Launcher registration and app opening** — added after Phase 4, outside the
  numbered plan, which never assigned them a phase. The home buttons now open
  real apps and the app can become the phone's home screen. Native, and
  unverified from this environment — see `## The launcher half is native` below.
- **Phase 5 (pairing and recovery)** — next. The 4-digit code, the install link
  and recovery are not built; Phase 4 links by the profile's 8-character
  `customer_code` instead, and `SeniorLinkController.connect` is the seam the
  Phase 5 flows plug into.

Route `/` is a launch gate, not a screen: a senior with a saved screen mode
lands on their home instead of the splash, because this app becomes the phone's
launcher and pressing Home must not show a splash. The guardian half now reads
the session Supabase restored from disk.

## Where the dashboard departs from the uploaded design

The design carried four things the project docs rule out, and the docs won.
Restoring any of them means changing the PRD first, not just the screen:

- 약 알림 / 복약 기록 — PRD Out Of MVP.
- 보이스피싱 의심 전화 — PRD excludes call-content analysis; the feature is
  scoped to numbers absent from the contact list and is named for that.
- 실시간 위치 추적 — `06_PERMISSION_AND_POLICY` forbids the phrasing, since how
  it is described is what the senior consents to.
- 여러 보호자 초대 — free in the PRD, paid in the design.

The docs' 메시지 탭 has no design and is not built.

## Layout under large text

Raising the text size is the point of this app, so anything that only fits at
the default size is a bug. The app tile, the SOS pill and the pairing-code row
all scale down to fit rather than overflow — check new screens at 아주 크게.

`flutter test test/screenshots_test.dart` writes each screen to
`build/screenshots/`. There is no display here and no way to build an APK
(see below), so those PNGs are how layout gets reviewed.

## Supabase

Wired in as of Phase 4. `SUPABASE_ACCESS_TOKEN` in the environment is now a
working Management API token (the earlier value was the dashboard's masked
display copied as text; that is fixed).

Project: `jal 26.07`, ref `jnmvhdmxzonngqyicelx`, ap-southeast-1, PostgreSQL 17.
`SUPABASE_PROJECT_REF` holds the ref.

### Schema

`supabase/migrations/20260729000000_phase4_core.sql` is the whole Phase 4
schema and is already applied. Five tables — `guardian_accounts`,
`senior_profiles`, `senior_devices`, `guardian_senior_links`, `home_apps` — all
with RLS on, plus four RPCs (`ensure_guardian_account`, `create_senior_profile`,
`register_senior_device`, `replace_home_apps`). Phase 5 and Phase 6 tables are
deliberately absent.

Two deviations from `05_DATA_MODEL`, both load-bearing:

- `senior_devices.auth_user_id` — the senior is never asked to make an account,
  so their phone signs in **anonymously** and this column is what ties that
  anonymous user to the profile RLS lets it touch. Anonymous sign-ins are
  enabled on the project; turning them off breaks every senior device.
- `home_apps.client_id` — the launcher's own `LauncherApp.id`, so a rename or a
  recolour lands on the existing row instead of creating a second button.

`senior_profiles.screen_mode` and `font_size` are both nullable with no default.
Null means *nobody has chosen yet*: a guardian creates the profile before the
parent's phone connects, and defaulting `font_size` to `normal` would let that
silence shrink the text of a senior who had already set 아주 크게.

`tool/verify_supabase_phase4.py` walks the whole acceptance list against the
live project — sign-in, linking, device swap, both sync directions, and the RLS
denials — then deletes everything it made. Run it with
`SSL_CERT_FILE=/root/.ccr/ca-bundle.crt python3 tool/verify_supabase_phase4.py`;
without the CA bundle, and without a non-default `User-Agent`, the agent proxy
403s Python.

### Running the app against it

Nothing is committed. The keys arrive at build time:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://jnmvhdmxzonngqyicelx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<publishable key>
```

**A build with no keys still runs.** `SupabaseConfig.isConfigured` is false, and
every repository provider resolves to its `InMemory…` twin instead. Phases 0-3
were built with no backend and `flutter test` has no keys, so that fallback is
load-bearing, not a convenience — don't make any screen require a live client.

### Guardian sign-in is email-only

Kakao and Google have no OAuth client configured on the project, and only the
repo owner can add one. `GuardianStartScreen` still leads with both buttons —
that is a deliberate design decision, see the spec — but with a project attached
they now open a sheet saying the provider is being prepared and offer the email
route at `/guardian-login`. With no project attached they open the dashboard as
they did in Phase 3. Email sign-up needs confirmation (`mailer_autoconfirm` is
false), so signing up returns no session and the screen says to check the inbox.

## The launcher half is native, and unverified here

`android/app/src/main/kotlin/com/example/app/MainActivity.kt` is the only
non-Flutter code in the project. It does two things: opens other apps, and
answers whether this app is the phone's home app.

**None of it has ever run.** There is no Android SDK and no `kotlinc` in this
environment, so the Kotlin is not compiled by `flutter analyze` and not covered
by `flutter test` — the Dart side is tested against `FakeAppLauncher`, which
proves the app asks for the right thing, not that the phone answers. Anything
touching that file needs a real build before it can be called working.

Three decisions in it are load-bearing:

- **The `HOME` + `DEFAULT` intent-filter is what makes this a launcher.**
  Without it the phone never offers the app in its home-app chooser. It comes
  with `launchMode="singleTask"` and `stateNotNeeded="true"`, which launchers
  need so pressing Home brings the running task forward instead of stacking a
  second copy.
- **Pressing Home is delivered through `onNewIntent`, not a restart.** The
  activity is already running, so the HOME intent arrives as a new intent and
  is forwarded to Dart as `goHome`; `HomeKeyListener` sends the router back to
  `/`. Without it the home key does nothing whenever the senior is anywhere but
  the home screen — which is exactly when they reach for it.
- **The `<queries>` block is not boilerplate.** On Android 11+ an app cannot
  see another app it has not declared, so removing an entry does not degrade a
  home button, it makes it fail silently. Adding a new button category means
  adding its intent there too.

System apps (전화, 문자, 사진, 앨범) are opened by intent category so each phone
uses the apps its owner already has. Only 카카오톡 and 유튜브 are named by
package, because Android has no category for them. 전화 resolves to
`ACTION_DIAL` and never `ACTION_CALL` — `06_PERMISSION_AND_POLICY` requires the
user press call themselves, and that holds for the 전화 button exactly as it
does for SOS.

## No APK from this environment

`dl.google.com` is blocked by egress policy, which rules out both the Android
SDK and the Android Gradle Plugin. Don't spend time installing either. Building
an APK needs a local machine or CI.

## Conventions

- Tests come before implementation — see `.claude/skills/test-driven-development`.
- Never claim work passes without running the command and reading the output.
- Work on the branch assigned for the session; don't push to `main` directly.
