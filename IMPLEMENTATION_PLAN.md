# IMPLEMENTATION_PLAN.md

## Completed

| Milestone | Description                                                                                                                                       | Date       |
| :-------- | :------------------------------------------------------------------------------------------------------------------------------------------------ | :--------- |
| M0.0      | Documentation phase — PRD, TDD, AGENTS.md, MEMORY.md                                                                                              | 2026-07-26 |
| M0.1      | Project Scaffold & Build Pipeline — `pubspec.yaml`, directory structure, Freezed message models, constants, logger, code generation, verify build | 2026-07-26 |
| M1        | Network Layer — TCP framing, TCP client, TCP server, UDP discovery + 39 tests                                                                     | 2026-07-26 |
| M2        | Core Validation & Geometry — `validation.dart`, `geometry.dart` + 44 tests                                                                        | 2026-07-26 |
| M3        | Server Engine — `server_state.dart`, `state_machine.dart`, `game_loop.dart` + 40 tests                                                            | 2026-07-26 |

## In Progress

| Milestone | Description                                                                                                                                                               |
| :-------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **M4**    | **Client UI — Menu Screens** — Mode select screen, discovery screen, name entry screen, lobby screen. Forui widgets, Riverpod providers, connection wiring. Widget tests. |

## Next

| Milestone | Description                                                                                                                                                             | Depends On |
| :-------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :--------- |
| **M5**    | **Client UI — Game Play** — GameScreen, GamePainter (map, circle, players, flag), VirtualJoystick, InteractButton. Spectator vs player mode. Widget tests.              | M4         |
| **M6**    | **Server-Client Integration** — End-to-end flow: discover → join → lobby → countdown → play → capture/steal → victory → game over → return to lobby. Integration tests. | M3, M5     |
| **M7**    | **Polish & Interop** — Player name labels, countdown animation, victory screen, error handling UI. Stress test (100 clients). Interop testing with classmates.          | M6         |

## Backlog

| #    | Feature                                                 | MoSCoW | Notes                              |
| :--- | :------------------------------------------------------ | :----- | :--------------------------------- |
| B-01 | Sound effects (capture, steal, victory, countdown beep) | P1     | Requires audio asset pipeline      |
| B-02 | Haptic feedback on interact/steal                       | P1     | Device-dependent                   |
| B-03 | Server dashboard (connection stats, tick rate display)  | P1     | Debug tool for host                |
| B-04 | Player color customization                              | P2     | Requires protocol extension        |
| B-05 | Match history / stats screen                            | P2     | Adds storage dependency            |
| B-06 | Replay viewer                                           | P2     | Record + playback state messages   |
| B-07 | Bluetooth keyboard support (iPad)                       | P2     | Alternative input for tablet users |

## Future Ideas

| #    | Idea                                             | Notes                                       |
| :--- | :----------------------------------------------- | :------------------------------------------ |
| F-01 | Map variants (obstacles, different circle sizes) | Requires protocol v2 negotiation            |
| F-02 | Team mode (2v2, 3v3)                             | Major protocol extension                    |
| F-03 | Internet relay mode (STUN/TURN)                  | Breaks LAN-only constraint; adds infra cost |
| F-04 | Tournament bracket mode                          | Coordinator server, multiple rounds         |
