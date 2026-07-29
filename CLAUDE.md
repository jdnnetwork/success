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
flutter test             # currently 22 tests, all passing
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
- **Phase 4 (Supabase)** — next, and blocked on the access token below.

Route `/` is a launch gate, not a screen: a senior with a saved screen mode
lands on their home instead of the splash, because this app becomes the phone's
launcher and pressing Home must not show a splash. The guardian-session half of
that check is stubbed `false` until Phase 4.

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

Not yet wired in, and deliberately so — Supabase is **Phase 4**, and the Phase 0
plan explicitly removes `supabase_flutter` from `pubspec.yaml`. Don't add it
early.

The project (`jal 26.07`, ref `jnmvhdmxzonngqyicelx`, ap-southeast-1,
PostgreSQL 17) exists and is healthy. `SUPABASE_ACCESS_TOKEN` in the
environment is **not a working token**. It holds
`sbp_cc48` + 32 `•` characters + `d352` — the dashboard's masked display,
selected and copied as text — so every Management API call returns 401
"JWT could not be decoded". This is not a network or permissions problem;
don't debug it as one.

Supabase only shows a token in full at creation, so the original value is
unrecoverable and a new token has to be issued. Copying it needs the
dashboard's copy button: dragging over the text selects the mask again,
which is how the current value got there. Only the repo owner can replace
it, in the environment variable settings, and the change takes effect in the
next session rather than the current one.

## No APK from this environment

`dl.google.com` is blocked by egress policy, which rules out both the Android
SDK and the Android Gradle Plugin. Don't spend time installing either. Building
an APK needs a local machine or CI.

## Conventions

- Tests come before implementation — see `.claude/skills/test-driven-development`.
- Never claim work passes without running the command and reading the output.
- Work on the branch assigned for the session; don't push to `main` directly.
