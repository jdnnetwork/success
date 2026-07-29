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

- **Phase 0 (project setup)** — done. Riverpod, go_router, feature-first layout,
  mock repositories.
- **Phase 1 (senior launcher)** — done. Role split, screen-mode choice, easy and
  detailed home, SOS phone handoff. Verified green.
- **Phase 2 (local settings)** — next. Home-app model, add/remove/reorder,
  rename, button colour, font size, screen-mode persistence. Acceptance is that
  settings survive an app restart.

`shared_preferences` is declared but not used yet: `lib/data/senior_settings_repository.dart`
is still the in-memory mock. Replacing that mock with real persistence is the
core of Phase 2.

## Supabase

Not yet wired in, and deliberately so — Supabase is **Phase 4**, and the Phase 0
plan explicitly removes `supabase_flutter` from `pubspec.yaml`. Don't add it
early.

The project (`jal 26.07`, ref `jnmvhdmxzonngqyicelx`, ap-southeast-1,
PostgreSQL 17) exists and is healthy. `SUPABASE_ACCESS_TOKEN` in the
environment is **not a working token** — it holds the masked `sbp_xxxx••••`
string copied off the dashboard, so every Management API call returns 401
"JWT could not be decoded". Only the repo owner can fix that, in the
environment variable settings. Don't spend time debugging it as a network or
permissions problem.

## Conventions

- Tests come before implementation — see `.claude/skills/test-driven-development`.
- Never claim work passes without running the command and reading the output.
- Work on the branch assigned for the session; don't push to `main` directly.
