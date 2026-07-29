# Capture The Flag — CTF Mobile

> **📄 [Documentación de Implementación](docs/IMPLEMENTATION_DOCS.md)** — Cronología completa, arquitectura, commits, agentes de IA, y métricas.

Capture The Flag — LAN multiplayer mobile game for CC8 at Galileo University. One device hosts the server (spectator-only); others join via automatic UDP broadcast discovery. All projects interoperate through the shared CTF Protocol v1.2.0 over raw TCP/UDP sockets.

## Platforms

| Platform           | Status |
| :----------------- | :----- |
| iOS 15+            | ✅     |
| Android 8+         | ✅     |
| macOS 14+ (Sonoma) | ✅     |

## Quick Start

```bash
# Install dependencies
fvm flutter pub get

# Run code generation (after modifying Freezed/Riverpod annotated files)
dart run build_runner build --delete-conflicting-outputs

# Run on connected device
fvm flutter run

# Run tests
fvm flutter test

# Static analysis
fvm flutter analyze
```

## Architecture

```
lib/
├── core/          # Shared protocol models, constants, validation, geometry
├── network/       # TCP framing, client, server, UDP discovery (dart:io)
├── server/        # Game state, state machine, 20 Hz authoritative game loop
├── client/
│   ├── screens/   # 6 screens (mode select → discovery → lobby → game)
│   ├── painters/  # GamePainter (CustomPainter: map, circle, players, flag)
│   ├── input/     # VirtualJoystick (8-dir touch) + InteractButton
│   └── providers/ # 4 Riverpod providers (app mode, connection, game state, server)
└── shared/        # Logger
```

## Tech Stack

| Layer      | Technology                                |
| :--------- | :---------------------------------------- |
| Framework  | Flutter 3.44.8+ / Dart 3.12.2             |
| State      | Riverpod (manual Notifiers)               |
| Models     | Freezed sealed unions + json_serializable |
| UI         | Forui (shadcn/ui-inspired)                |
| Networking | dart:io raw TCP/UDP sockets               |
| Rendering  | CustomPainter + Canvas                    |
| Font       | Departure Mono (pixel-game theme)         |
| Logging    | logger                                    |

## Game Rules

Each player competes individually:

1. Enter the central circle (radius 300)
2. Take the flag (interact within 40 units)
3. Exit the circle completely (> 315 units from center) while carrying the flag

First player to achieve this wins. The flag can be stolen by any player within 40 units of the carrier. No collisions between players.

See [`docs/PROJECT_GUIDE.md`](docs/PROJECT_GUIDE.md) for full rules.

## Protocol

Implements the [CTF Protocol Standard v1.2.0](docs/SPEC.md) — 12 message types over newline-delimited JSON on TCP, plus UDP broadcast discovery on port 8888.

See [`docs/SPEC.md`](docs/SPEC.md) for the full specification.

## Controls

| Input                    | Action                 |
| :----------------------- | :--------------------- |
| Virtual joystick (touch) | 8-directional movement |
| W/A/S/D or Arrow keys    | Movement (keyboard)    |
| Interact button (touch)  | Capture/steal flag     |
| E or Space (keyboard)    | Capture/steal flag     |

## Documentation

| Document                                                | Content                                                |
| :------------------------------------------------------ | :----------------------------------------------------- |
| [`IMPLEMENTATION_DOCS.md`](docs/IMPLEMENTATION_DOCS.md) | Full implementation history, commits, AI agents, fixes |
| [`PRD.md`](docs/PRD.md)                                 | Product Requirements Document                          |
| [`TDD.md`](docs/TDD.md)                                 | Technical Design Document                              |
| [`PROJECT_GUIDE.md`](docs/PROJECT_GUIDE.md)             | Game rules (English)                                   |
| [`SPEC.md`](docs/SPEC.md)                               | Protocol specification v1.2.0                          |
| [`AGENTS.md`](AGENTS.md)                                | AI agent orchestration rules                           |
| [`MEMORY.md`](MEMORY.md)                                | Persistent project knowledge                           |

## Metrics

| Metric             | Value   |
| :----------------- | :------ |
| Source files       | 30+     |
| Test files         | 9       |
| Tests              | 124     |
| Commits            | 11      |
| AI agents deployed | 23      |
| Lines of code      | ~5,000+ |
