# 잘보이네 v2 — Senior Launcher

A Flutter app with two sides: a simplified Android launcher for 피보호자 (the senior
user), and a guardian-facing dashboard for the family member who sets it up.

## Read first

Planning docs live in `docs/claude-code/`, converted from the original
`잘보이네v2.docx`. Read them in order — `01_PRODUCT_PRD` → `02_MVP_SCOPE` →
`03_USER_FLOWS` → `04_SCREEN_SPEC` → `05_DATA_MODEL` → `06_PERMISSION_AND_POLICY`
→ `07_PHASE_PLAN_FOR_CLAUDE_CODE`.

`07_PHASE_PLAN_FOR_CLAUDE_CODE.md` is the source of truth for what to build next
and what "done" means for each phase. **Build one phase at a time.** Do not
implement the whole app from the PRD in one pass.

## Stack

- Flutter, Dart SDK `^3.10.8`
- `flutter_riverpod` for state, `go_router` for routing
- `shared_preferences` for local persistence
- `url_launcher` for the phone handoff
- Supabase is planned for the backend but not yet wired in

## Layout

```
lib/core/       theme (app_colors, app_theme), router (routes, app_router)
lib/domain/     models — senior_settings, launcher_app, app_category
lib/data/       repositories — senior_settings_repository, phone_dialer
lib/features/   launcher/ onboarding/ guardian/ family/
                each split into presentation/ application/ data/
test/           mirrors lib/ structure; test/support/pump_app.dart is the harness
```

## Product rules that are not negotiable

- **SOS must never auto-dial.** It opens the phone app with the number filled in
  and stops there. The user presses call. `PhoneDialer` is written so auto-calling
  is not expressible — keep it that way.
- The senior side gets no extra onboarding questions beyond the screen-mode choice.
- Easy mode and detailed mode must render distinctly, not as a font-size variant.

## Working agreements

- Tests accompany each feature. Run `flutter test` before calling a phase done.
- `dart format .` before committing.
- Conventional commit prefixes (`feat:`, `refactor:`, `style:`, `chore:`).

## Where things stand

Phase 0 (project setup) and Phase 1 (피보호자 런처 UI) are implemented: role-split
splash, screen-mode choice, easy home (2x2 grid), detailed home with add-slots and
bottom tabs, SOS screen, and placeholders for guardian login, family link, and more-apps.
22 Dart files, 13 test files.

Phase 2 (local settings persistence) is the next phase in the plan.

## Open questions — ask before assuming

1. **Rebuild vs. continue.** The owner raised rebuilding the app code from
   scratch rather than extending Phase 0–1. Unresolved. The planning docs and the
   test suite are the assets worth keeping either way; `lib/` is ~1,155 lines and
   cheap to redo. Confirm the intent before doing large-scale deletion.
2. **Supabase wiring.** Not connected yet. Decide read-only vs. read-write MCP
   access, and how it lands against the schema in `05_DATA_MODEL.md`.

## Environment notes

Develop locally. Cloud sessions have no Flutter toolchain, no emulator, and no way
to see a rendered screen — which does not work for a UI-first project like this one.
Use `claude --cloud` selectively for work that doesn't need to run the app.

Superpowers is vendored at `.claude/skills/superpowers/`, so it loads in every
session with no install step. See that folder's `VENDORED.md` before updating it.
