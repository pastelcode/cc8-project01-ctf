# CURRENT_SPRINT.md

## Sprint Objective

**MVP Complete** — All M0 through M7 milestones implemented. Game is fully playable: host server, discover, join, lobby, countdown, gameplay with 8-dir movement + flag capture/steal, victory, game over, return to lobby.

## Current Milestone

**Milestone 7: Polish & Interop** ✅ Complete

**Status:** MVP implementation done. Remaining: manual interop testing with classmates.

## Completed Milestones

| #   | Milestone                                                           | Status |
| :-- | :------------------------------------------------------------------ | :----: |
| M0  | Documentation (PRD, TDD, AGENTS, MEMORY)                            |   ✅   |
| M1  | Network Layer (framing, client, server, discovery)                  |   ✅   |
| M2  | Core Validation & Geometry                                          |   ✅   |
| M3  | Server Engine (state, state machine, game loop)                     |   ✅   |
| M4  | Client UI — Menu Screens                                            |   ✅   |
| M5  | Game Screen (painter, joystick, interact, overlays)                 |   ✅   |
| M6  | Server-Client Integration                                           |   ✅   |
| M7  | Polish (name labels, countdown animation, error toast, stress test) |   ✅   |

## Current Blockers

_(None.)_

## Remaining Work

| Task                                 | Priority | Owner   |
| :----------------------------------- | :------: | :------ |
| Interop testing with ≥ 3 classmates  |    P0    | Dev     |
| Build and deploy to physical devices |    P0    | Dev     |
| Sound effects                        |    P1    | Backlog |
| Haptic feedback                      |    P1    | Backlog |
| Server dashboard                     |    P1    | Backlog |

## Sprint Success Criteria

- [x] Full server-client flow (host → lobby → countdown → game → victory → game over → lobby)
- [x] All 7 app modes wired in AppShell
- [x] Game rendering: map, circle, players, flag, name labels
- [x] 8-directional virtual joystick + interact button
- [x] Countdown animation (scale + fade + color ramp)
- [x] Error toast notifications for server errors
- [x] Stress test: 100 concurrent clients, no crashes
- [x] `dart format` passes on all files
- [x] `flutter analyze` passes with zero errors
- [x] Full test suite: 123/124 tests passing (1 pre-existing flaky UDP broadcast)
- [ ] Interop testing with classmates
- [ ] Physical device build verified
