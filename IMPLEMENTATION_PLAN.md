# IMPLEMENTATION_PLAN.md

## Completed

| Milestone | Description                                                                                   | Date       |
| :-------- | :-------------------------------------------------------------------------------------------- | :--------- |
| M0.0      | Documentation phase — PRD, TDD, AGENTS.md, MEMORY.md                                          | 2026-07-26 |
| M0.1      | Project Scaffold & Build Pipeline                                                             | 2026-07-26 |
| M1        | Network Layer — TCP framing, client, server, UDP discovery + 39 tests                         | 2026-07-26 |
| M2        | Core Validation & Geometry + 44 tests                                                         | 2026-07-26 |
| M3        | Server Engine — state, state machine, game loop + 40 tests                                    | 2026-07-26 |
| M4        | Client UI — Menu Screens (mode select, discovery, name entry, lobby, server name)             | 2026-07-26 |
| M5        | Game Screen — GamePainter, VirtualJoystick, InteractButton, overlays, game_state_provider     | 2026-07-26 |
| M6        | Server-Client Integration — server provider, lobby wiring, game transitions, post-game return | 2026-07-26 |

## In Progress

| Milestone | Description                                                                                                                           |
| :-------- | :------------------------------------------------------------------------------------------------------------------------------------ |
| **M7**    | **Polish & Interop** — Player name labels, countdown animation, error UI. Stress test (100 clients). Interop testing with classmates. |

## Next

_(None — M7 is the final MVP milestone.)_

## Backlog

| #    | Feature                                                 | MoSCoW | Notes                            |
| :--- | :------------------------------------------------------ | :----- | :------------------------------- |
| B-01 | Sound effects (capture, steal, victory, countdown beep) | P1     | Audio asset pipeline             |
| B-02 | Haptic feedback on interact/steal                       | P1     | Device-dependent                 |
| B-03 | Server dashboard (connection stats, tick rate display)  | P1     | Debug tool for host              |
| B-04 | Player color customization                              | P2     | Requires protocol extension      |
| B-05 | Match history / stats screen                            | P2     | Adds storage dependency          |
| B-06 | Replay viewer                                           | P2     | Record + playback state messages |

## Future Ideas

| #    | Idea                                             | Notes                               |
| :--- | :----------------------------------------------- | :---------------------------------- |
| F-01 | Map variants (obstacles, different circle sizes) | Protocol v2                         |
| F-02 | Team mode (2v2, 3v3)                             | Major protocol extension            |
| F-03 | Internet relay mode (STUN/TURN)                  | Breaks LAN-only constraint          |
| F-04 | Tournament bracket mode                          | Coordinator server, multiple rounds |
