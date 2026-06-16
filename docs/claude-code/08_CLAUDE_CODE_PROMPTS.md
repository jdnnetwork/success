# Claude Code Prompts

Use these prompts step by step. Do not paste all of them at once.

## Prompt 1: Read And Normalize Requirements
```text
Read all files in docs/claude-code.

Do not code yet.

Create a short implementation-readiness report with:
1. confirmed MVP scope
2. phase order
3. unresolved questions
4. technical risks
5. files/modules you expect to create

If any docs conflict, list the conflict and recommend one interpretation.
```

## Prompt 2: Phase 0 Plan
```text
Use docs/claude-code as the source of truth.

Plan Phase 0 only:
- Flutter project structure
- routing
- theme
- mock repository interfaces
- local models

Do not implement until I approve the plan.
```

## Prompt 3: Phase 0 Implementation
```text
Implement the approved Phase 0 plan.

Rules:
- keep code modular
- no Supabase yet
- no paid feature implementation yet
- include loading / empty / error state patterns where relevant
- run formatting and tests or explain why they cannot run
```

## Prompt 4: Phase 1 Plan
```text
Plan Phase 1 only: 피보호자 런처 UI.

Scope:
- first role split screen
- senior onboarding
- really easy screen
- detailed screen
- SOS phone handoff
- no extra onboarding questions

Do not implement until I approve.
```

## Prompt 5: Phase 1 Implementation
```text
Implement Phase 1.

Important:
- onboarding asks no questions except screen mode choice
- SOS opens phone screen with number and does not auto-call
- senior UI must prioritize large buttons, large text, and shallow navigation
- do not implement backend, payment, location, call detection, or app install detection
```

## Prompt 6: Phase 2 Plan
```text
Plan Phase 2 only: local settings and home app configuration.

Scope:
- home app model
- add/remove/reorder
- rename
- button color
- font size
- mode persistence

Use local storage first. Keep repository interfaces ready for Supabase later.
```

## Prompt 7: Supabase Schema
```text
Based on docs/claude-code/05_DATA_MODEL.md, create Supabase schema migrations.

Do not wire the UI yet.

Include:
- guardian_accounts
- senior_profiles
- senior_devices
- guardian_senior_links
- home_apps
- messages
- recovery_links
- pair_links
- subscriptions
- alerts

Also add row-level security policy recommendations.
```

## Prompt 8: Pairing And Recovery
```text
Implement pairing and recovery according to docs/claude-code/03_USER_FLOWS.md and 05_DATA_MODEL.md.

Scope:
- 4-digit code pairing
- guardian invite link
- parent phone reconnect
- recovery link or 6-digit recovery code
- old senior_device deactivation

Do not implement paid features in this phase.
```

## Prompt 9: Paid Features Planning
```text
Plan paid features only.

Scope:
- care plan 5,900 KRW
- family plan 8,900 KRW
- senior consent after guardian payment
- refusal -> refunded subscription state
- family plan parent switcher
- 5-minute background sync interface
- permission fallback states

Do not implement until I approve.
```

## Standing Rules For Claude Code
```text
Always follow these rules:
- docs/claude-code is the source of truth.
- Implement only the requested phase.
- If a feature is out of scope, create an interface or TODO stub only when useful.
- Ask before changing scope.
- For senior-facing UI, prefer larger text, larger tap targets, fewer choices, and fewer navigation depths.
- For guardian-facing UI, prefer clean dashboard patterns and efficient scanning.
- Always include offline, loading, empty, and error states where they affect user flow.
- Run verification before claiming completion.
```

