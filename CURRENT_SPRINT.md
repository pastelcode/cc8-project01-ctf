# CURRENT_SPRINT.md

## Sprint Objective

**Sprint 1: Network & Server Core** — Implement the entire backend: network layer, core validation/geometry, and server game engine. All modules must compile, format cleanly, pass analysis, and have tests.

## Current Milestone

**Milestone 3: Server Engine** ✅ Complete

**Milestone 4: Client UI — Menu Screens** — Next

## Active Tasks

| #    | Task                                                                                                | Status  | Owner |
| :--- | :-------------------------------------------------------------------------------------------------- | :-----: | :---- |
| T-08 | Implement `lib/client/providers/app_mode_provider.dart` — Riverpod provider for app mode state      | ⬜ TODO | AI    |
| T-09 | Implement `lib/client/screens/mode_select_screen.dart` — Host/Join buttons using Forui              | ⬜ TODO | AI    |
| T-10 | Implement `lib/client/app_shell.dart` — screen switching by AppMode                                 | ⬜ TODO | AI    |
| T-11 | Implement `lib/client/screens/discovery_screen.dart` — server list + manual IP, using UDP discovery | ⬜ TODO | AI    |
| T-12 | Implement `lib/client/screens/name_entry_screen.dart` — player name input                           | ⬜ TODO | AI    |
| T-13 | Implement `lib/client/screens/lobby_screen.dart` — player list, start button, countdown overlay     | ⬜ TODO | AI    |
| T-14 | Wire `lib/main.dart` to Forui wrapper and AppShell                                                  | ⬜ TODO | AI    |

## Completed Sprint Tasks

All 7 Sprint 0 tasks + 6 backend implementation tasks completed.

| Milestone | Description                                                                   | Status |
| :-------- | :---------------------------------------------------------------------------- | :----: |
| M0.1      | Project scaffold, pubspec.yaml, messages, constants, logger, build_runner     |   ✅   |
| M1        | Network Layer (tcp_framing, tcp_client, tcp_server, udp_discovery) + 39 tests |   ✅   |
| M2        | Core Validation & Geometry (validation.dart, geometry.dart) + 44 tests        |   ✅   |
| M3        | Server Engine (server_state, state_machine, game_loop) + 40 tests             |   ✅   |

## Next Recommended Task

**M4: Client UI — Menu Screens.** Begin with T-08 (`app_mode_provider.dart`), then T-09 (`mode_select_screen.dart`) paired with T-14 (wire `main.dart` to Forui + AppShell). Then T-10 (`app_shell.dart`), followed by discovery screen, name entry, and lobby screen.

## Current Blockers

_(None.)_

## Pending Engineering Decisions

| #    | Decision                                                                                                | Status                                                                                       |
| :--- | :------------------------------------------------------------------------------------------------------ | :------------------------------------------------------------------------------------------- |
| D-01 | Forui version to pin (check latest compatible with Flutter 3.44.8+)                                     | Resolved — `^0.24.3`                                                                         |
| D-02 | Whether to use `riverpod_generator` for ALL providers or only some (manual `Notifier` for complex ones) | Resolved — manual `Notifier` providers (riverpod_generator omitted due to version conflicts) |
| D-03 | Coordinate system for virtual joystick — absolute position or delta from center?                        | Pending (TDD specifies delta from center with dead zone)                                     |

## Documents Updated This Sprint

- `docs/PRD.md` — created
- `docs/TDD.md` — created
- `AGENTS.md` — created
- `MEMORY.md` — created
- `CURRENT_SPRINT.md` — updated with M1-M3 progress
- `IMPLEMENTATION_PLAN.md` — pending update
- `CHANGELOG.md` — created

## Sprint Success Criteria

- [x] All 7 M0.1 tasks completed (scaffold & build)
- [x] M1: Network layer implemented with tests (tcp_framing, tcp_client, tcp_server, udp_discovery)
- [x] M2: Validation & geometry implemented with tests (validation.dart, geometry.dart)
- [x] M3: Server engine implemented with tests (server_state, state_machine, game_loop)
- [x] `dart format` passes on all files
- [x] `flutter analyze` passes with zero errors
- [x] Full test suite: 123 tests passing
- [ ] M4: Client UI — menu screens (mode select, discovery, name entry, lobby)
- [ ] M5: GameScreen + CustomPainter + input widgets
- [ ] Project compiles (`flutter build` succeeds for at least one target)
