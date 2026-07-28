# CURRENT_SPRINT.md

## Sprint Objective

**Sprint 2: Client UI & Integration** — Implement all client screens, game rendering, input widgets, and wire the full server-client flow end-to-end.

## Current Milestone

**Milestone 6: Server-Client Integration** ✅ Complete

**Milestone 7: Polish & Interop** — Next (final MVP milestone)

## Active Tasks

| #    | Task                                                     | Status  | Owner |
| :--- | :------------------------------------------------------- | :-----: | :---- |
| T-15 | Add player name labels above avatars in-game             | ⬜ TODO | AI    |
| T-16 | Improve countdown animation (scale/color transitions)    | ⬜ TODO | AI    |
| T-17 | Add error handling UI (snackbar/toast for server errors) | ⬜ TODO | AI    |
| T-18 | Stress test with 100 concurrent mock clients             | ⬜ TODO | AI    |
| T-19 | Interop testing with classmates                          | ⬜ TODO | Dev   |

## Completed Milestones

| Milestone | Description                                                                 | Status |
| :-------- | :-------------------------------------------------------------------------- | :----: |
| M0.0      | Documentation phase                                                         |   ✅   |
| M0.1      | Project Scaffold & Build Pipeline                                           |   ✅   |
| M1        | Network Layer (framing, client, server, discovery)                          |   ✅   |
| M2        | Core Validation & Geometry                                                  |   ✅   |
| M3        | Server Engine (state, state machine, game loop)                             |   ✅   |
| M4        | Client UI — Menu Screens (mode select, discovery, name entry, lobby)        |   ✅   |
| M5        | Game Screen (painter, joystick, interact button, overlays)                  |   ✅   |
| M6        | Server-Client Integration (server provider, lobby wiring, game transitions) |   ✅   |

## Next Recommended Task

**M7: Polish.** Add player name labels on the game canvas, improve countdown visuals, add error toast notifications. Then stress test and interop test.

## Current Blockers

_(None.)_

## Sprint Success Criteria

- [x] M4: All menu screens implemented and wired
- [x] M5: Game screen with painter, joystick, interact button
- [x] M6: Full server-client flow (host → lobby → countdown → game → game over → lobby)
- [x] `dart format` passes on all files
- [x] `flutter analyze` passes with zero errors
- [x] Full test suite: 122/123 tests passing
- [ ] M7: Polish (name labels, countdown animation, error UI)
- [ ] Stress test: 100 concurrent clients
- [ ] Interop test: ≥ 3 classmates
- [ ] Project compiles (`flutter build` succeeds)
