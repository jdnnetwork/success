# Phase Plan For Claude Code

## Important Instruction
Do not implement all phases at once. Each phase must be implemented, reviewed, and tested independently.

## Phase 0: Project Setup
Output:
- Flutter project structure
- routing
- theme base
- local state management choice
- mock repositories

Acceptance:
- app runs
- first screen renders
- no Supabase required

## Phase 1: 피보호자 런처
Output:
- role split first screen
- senior onboarding
- screen mode choice
- easy home
- detailed home
- SOS phone handoff
- return-to-original placeholder

Acceptance:
- user can choose mode
- app shows correct default buttons
- no extra onboarding questions
- SOS opens phone intent, does not auto-call

## Phase 2: Local Settings
Output:
- home apps local model
- add/remove/reorder
- rename
- button color change
- font size change
- screen mode persistence

Acceptance:
- settings survive app restart
- easy and detailed mode render differently
- app buttons are stable across states

## Phase 3: Guardian Dashboard UI
Output:
- guardian login placeholder
- dashboard shell
- parent status card
- home management tab
- message tab
- care tab
- settings tab
- family plan parent switcher UI

Acceptance:
- dashboard can be navigated without backend
- parent switcher renders in mock mode
- empty/loading/error/offline states exist

## Phase 4: Supabase Integration
Output:
- schema migration
- auth integration for guardian
- repositories
- senior profile creation
- senior device creation
- guardian-senior linking

Acceptance:
- guardian can login
- senior profile can be linked
- home app settings sync when parent phone is online

## Phase 5: Pairing And Recovery
Output:
- 4-digit pairing code
- invite link
- recovery link/code
- reconnect parent phone
- old device deactivation
- primary guardian change
- family guardian invite

Acceptance:
- reinstall can restore existing senior profile
- family guardian invite is free
- primary guardian change requires senior phone approval

## Phase 6: Paid Features
Output:
- subscription model
- care plan
- family plan
- senior consent flow
- refund state for refusal
- 5-minute background sync interface
- location interface
- unknown-contact call alert interface
- app install alert interface

Acceptance:
- paid features do not activate before senior consent
- refusal results in refunded subscription state
- family plan unlocks 2+ parent management

