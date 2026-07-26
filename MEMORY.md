# MEMORY.md

## Product Vision

A zero-infra, LAN-party mobile game where up to 100 players compete in capture-the-flag rounds. One device hosts the server (spectator-only); others join via automatic UDP broadcast discovery. All CC8 class projects interoperate through the shared CTF protocol (SPEC v1.2.0). No accounts, no cloud, no internet — just a shared Wi-Fi network.

## Architecture

### High-Level Pattern

**Monolithic Flutter app, dual-mode.** Single binary operates as either:

- **Server Mode (Host):** In-process TCP game server + UDP discovery listener + spectator-only rendering. Host cannot play.
- **Client Mode (Joiner):** UDP discovery → TCP connection → player-controlled rendering with virtual joystick and interact button.

### Layer Isolation (Strict)

```
core/          → Pure Dart, no Flutter. Shared protocol models, constants, validation, geometry.
network/       → Pure Dart + dart:io. TCP framing, TCP client/server, UDP discovery.
server/        → Pure Dart + dart:io. Game loop (20 Hz), state machine, session management.
client/        → Flutter. Screens, painters, input widgets, Riverpod providers.
shared/        → Flutter-aware utilities (logger).

Dependency rule: client/ and server/ NEVER import each other.
                 client/ → network/ → core/
                 server/ → network/ → core/
```

### Directory Map

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── messages.dart              # Freezed sealed union — all 12 message types
│   ├── constants.dart             # Protocol constants (all values from SPEC §2.3)
│   ├── validation.dart            # Name sanitization, field type checks
│   └── geometry.dart              # Distance, clamp, spawn position, victory check
├── network/
│   ├── tcp_framing.dart           # Buffer accumulator, newline split, coalescence
│   ├── tcp_client.dart            # Connect, send ClientMessage, Stream<ServerMessage>
│   ├── tcp_server.dart            # Listen, accept N clients, broadcast/coalescible send
│   └── udp_discovery.dart         # Broadcast discover, listen server_info, manual IP
├── server/
│   ├── server_state.dart          # Immutable game world state
│   ├── server_state_machine.dart  # Lobby → Countdown → Playing → GameOver → Lobby
│   └── server_game_loop.dart      # Timer.periodic(50ms), tick logic, broadcast
├── client/
│   ├── app_shell.dart
│   ├── screens/
│   │   ├── mode_select_screen.dart
│   │   ├── server_name_screen.dart
│   │   ├── discovery_screen.dart
│   │   ├── name_entry_screen.dart
│   │   ├── lobby_screen.dart
│   │   └── game_screen.dart
│   ├── painters/
│   │   └── game_painter.dart
│   ├── input/
│   │   ├── virtual_joystick.dart
│   │   └── interact_button.dart
│   └── providers/
│       ├── app_mode_provider.dart
│       ├── discovery_provider.dart
│       ├── connection_provider.dart
│       ├── game_state_provider.dart
│       └── server_provider.dart
└── shared/
    └── logger.dart
```

## Technology Stack

### Core

| Category | Choice | Version |
| :------- | :----- | :------ |
| Language | Dart | 3.12.2+ |
| Framework | Flutter | 3.44.8+ |
| Platforms | iOS 15+, Android 8+ | — |

### State & Data

| Category | Choice | Notes |
| :------- | :----- | :---- |
| State management | Riverpod | With `riverpod_generator` (code-gen) |
| Data classes | Freezed | Sealed unions with `@freezed` |
| JSON serialization | json_serializable | Via `build_runner` |
| Logging | logger | Debug mode: log all sent/recv messages |

### Networking

| Category | Choice | Notes |
| :------- | :----- | :---- |
| TCP | dart:io `Socket` / `ServerSocket` | Native only — no third-party. Newline-delimited JSON framing. |
| UDP | dart:io `RawDatagramSocket` | Discovery only — fixed port 8888, `SO_BROADCAST`, `SO_REUSEADDR`. |
| Max connections | 100 | Per SPEC. Async I/O, single isolate. |

### UI & Rendering

| Category | Choice | Notes |
| :------- | :----- | :---- |
| UI components | Forui | shadcn/ui-inspired. Buttons, cards, dialogs, overlays. |
| Game canvas | CustomPainter + Canvas | No Flame. Simple shapes, coordinate transform from logical (1000×1000) to screen pixels. |
| Input | Touch widgets | Virtual joystick (8-directional), interact button. Optional Bluetooth keyboard. |

### Testing

| Category | Choice |
| :------- | :----- |
| Unit | `flutter_test` |
| Widget | `flutter_test` |
| Integration | `flutter_test` (integration_test package) |
| Linting | `flutter_lints` ^6.0.0 |

## Domain Terminology

| Term | Definition |
| :--- | :--------- |
| **CTF** | Capture The Flag — the game mode |
| **Flag (bandera)** | The contestable object. Owned by one player at most (`null` when free). Always at (500,500) when free. |
| **Portador (carrier)** | The player currently holding the flag |
| **Capture (captura)** | Taking the flag when it's free (distance ≤ 40 from center) |
| **Steal (robo)** | Taking the flag from the carrier (distance ≤ 40 from carrier) |
| **Victory** | Carrier exits the circle outward — must transition from distance ≤ 315 to > 315 from center |
| **Lobby** | Waiting room before countdown. Players join, host sees list, host triggers start. |
| **Countdown** | 5-second (5, 4, 3, 2, 1) pre-game phase. Aborts if players drop below 2. |
| **Tick** | 50ms server loop (20 Hz). Movement integration, victory check, interaction processing, state broadcast. |
| **Coalescence** | Server discards pending `state` messages for slow clients, sends only the most recent. |
| **Framing** | Each TCP message is `JSON\n`. Buffer accumulates bytes, splits at `\n`, parses. |

## Protocol Constants (SPEC §2.3)

| Constant | Value | Meaning |
| :------- | :---- | :------ |
| `map_size` | 1000 | 1000×1000 logical units |
| `circle_radius` | 300 | Central circle radius |
| `circle_center` | (500, 500) | Center of map and circle |
| `player_radius` | 15 | Player body radius |
| `interact_radius` | 40 | Max distance to capture/steal |
| `speed` | 200 | Units per second |
| `tick_rate` | 20 | State broadcasts per second |
| `countdown_seconds` | 5 | Pre-game countdown |
| `min_players` | 2 | Minimum to start/continue countdown |
| `post_game_seconds` | 5 | Pause after game_over before lobby |
| `spawn_radius` | 350–450 | Spawn ring (random angle, random radius in range) |
| `victory_distance` | 315 | circle_radius + player_radius — must exceed to win |
| `discovery_port` | 8888 | Fixed UDP discovery port |
| `max_players` | 100 | Maximum connections |
| `name_max_length` | 20 | Max player name characters |
| `message_max_size` | 64 KB | Max message size |

## Protocol Message Catalog

| Type | Direction | Phase | Purpose |
| :--- | :-------- | :---- | :------ |
| `discover` | C → UDP | Any | Search for servers |
| `server_info` | S → UDP | Any | Advertise server |
| `join` | C → S TCP | Lobby | Enter lobby |
| `input` | C → S TCP | Playing | Movement intent (dir.x/dir.y) |
| `interact` | C → S TCP | Playing | Capture/steal flag |
| `welcome` | S → C TCP | Lobby | Assign player_id + config |
| `lobby` | S → C TCP | Lobby | Player list + return-to-lobby signal |
| `countdown` | S → C TCP | Countdown | Seconds remaining |
| `start` | S → C TCP | Countdown→Playing | Match begins |
| `state` | S → C TCP | Playing | World snapshot (coalescible) |
| `game_over` | S → C TCP | Playing→GameOver | Winner announcement |
| `error` | S → C TCP | Any | Rejection reason |

## Key Design Decisions

1. **No Flame** — CustomPainter is simpler, lighter, and sufficient. All game logic is server-side; client just renders received state.
2. **Host is spectator-only** — per project guide. Server renders all players but gives no controls. To play, host must join from a separate device.
3. **Freezed sealed unions for messages** — compile-time exhaustiveness, `copyWith`, auto `toJson`/`fromJson`.
4. **Enums over raw strings** — `ServerState`, `GamePhase`, `ErrorReason` all have `@JsonValue` annotations for wire mapping.
5. **Async I/O, single isolate** — 100 concurrent TCP connections handled cleanly by Dart's event loop. Isolates add serialization overhead that would hurt tick stability.
6. **In-memory state** — no database. State lives for one match lifetime. Reset on server restart.
7. **Coalescible `state` broadcasts** — slow clients get only the latest snapshot, preventing memory growth and backlog.

## Permanent Constraints

- **No third-party networking libraries.** `dart:io` raw sockets only (SPEC §1.1).
- **Protocol version locked at v=1.** No custom extensions without class-wide agreement (SPEC §7.2).
- **No encryption or authentication.** Protocol v1 transmits in plaintext over LAN (SPEC §6.1).
- **All game logic is server-authoritative.** Client sends intent (`dir`, `interact`); server calculates outcome.
- **Message size ≤ 64 KB.** Violations close the connection.
- **Names ≤ 20 chars UTF-8**, trimmed, no control chars.
- **Max 100 players per server.**
