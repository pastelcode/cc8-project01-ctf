# IMPLEMENTATION_PLAN.md

## Completed

| Milestone | Description | Date |
| :-------- | :---------- | :--- |
| M0.0 | Documentation phase — PRD, TDD, AGENTS.md, MEMORY.md | 2026-07-26 |

## In Progress

| Milestone | Description |
| :-------- | :---------- |
| **M0.1** | **Project Scaffold & Build Pipeline** — `pubspec.yaml`, directory structure, Freezed message models, constants, logger, code generation, verify build |

## Next

| Milestone | Description | Depends On |
| :-------- | :---------- | :--------- |
| **M1** | **Network Layer** — TCP framing (`tcp_framing.dart`), TCP client (`tcp_client.dart`), TCP server (`tcp_server.dart`), UDP discovery (`udp_discovery.dart`). Unit tests for framing and message round-trips. | M0.1 |
| **M2** | **Core Validation & Geometry** — `validation.dart` (name, dir, size checks), `geometry.dart` (distance, clamp, spawn, victory check). Full unit test coverage. | M0.1 |
| **M3** | **Server Engine** — `server_state.dart`, `server_state_machine.dart`, `server_game_loop.dart`. Tick logic, phase transitions, victory detection. Unit tests for state machine and game loop. | M1, M2 |
| **M4** | **Client UI — Menu Screens** — Mode select, server name entry, discovery screen, name entry, lobby screen. Forui widgets, Riverpod providers, connection wiring. Widget tests. | M1, M2 |
| **M5** | **Client UI — Game Play** — GameScreen, GamePainter (map, circle, players, flag), VirtualJoystick, InteractButton. Spectator vs player mode. Widget tests + golden tests. | M4 |
| **M6** | **Server-Client Integration** — End-to-end flow: discover → join → lobby → countdown → play → capture/steal → victory → game over → return to lobby. Integration tests. | M3, M5 |
| **M7** | **Polish & Interop** — Player name labels, countdown animation, victory screen, error handling UI. Stress test (100 clients). Interop testing with classmates. | M6 |

## Backlog

| # | Feature | MoSCoW | Notes |
| :-- | :------ | :----- | :---- |
| B-01 | Sound effects (capture, steal, victory, countdown beep) | P1 | Requires audio asset pipeline |
| B-02 | Haptic feedback on interact/steal | P1 | Device-dependent |
| B-03 | Server dashboard (connection stats, tick rate display) | P1 | Debug tool for host |
| B-04 | Player color customization | P2 | Requires protocol extension |
| B-05 | Match history / stats screen | P2 | Adds storage dependency |
| B-06 | Replay viewer | P2 | Record + playback state messages |
| B-07 | Bluetooth keyboard support (iPad) | P2 | Alternative input for tablet users |

## Future Ideas

| # | Idea | Notes |
| :-- | :--- | :---- |
| F-01 | Map variants (obstacles, different circle sizes) | Requires protocol v2 negotiation |
| F-02 | Team mode (2v2, 3v3) | Major protocol extension |
| F-03 | Internet relay mode (STUN/TURN) | Breaks LAN-only constraint; adds infra cost |
| F-04 | Tournament bracket mode | Coordinator server, multiple rounds |
