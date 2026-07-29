# Implementation Documentation — Capture The Flag (CTF)

> **Project:** CC8 2026 — Capture The Flag  
> **Language:** Dart 3.12.2 / Flutter 3.44.8+  
> **Protocol:** CTF Standard v1.2.0  
> **Author:** CC8 — Individual Project  
> **Period:** July 26–28, 2026

---

## 1. Development Timeline

### Day 1 — July 26, 2026: Documentation and Architecture

**Objective:** Define the MVP scope, technology stack, system architecture, and prepare the development environment.

| Time  | Activity                                                                                                             |
| :---- | :------------------------------------------------------------------------------------------------------------------- |
| 14:45 | **Commit `94bf06c`** — Initial documentation                                                                         |
|       | Stack defined: Flutter 3.44.8+, Dart 3.12.2, Riverpod, Freezed, Forui, dart:io, logger, CustomPainter                |
|       | Removed Flame (unnecessary — CustomPainter sufficient for simple 2D rendering)                                       |
|       | Confirmed: host = spectator only, client = player with controls                                                      |
|       | Decided to use enums with `@JsonValue` instead of raw strings for `ServerState`, `GamePhase`, `ErrorReason`          |
|       | Created: `PRD.md`, `TDD.md`, `MEMORY.md`, `AGENTS.md`, `CURRENT_SPRINT.md`, `IMPLEMENTATION_PLAN.md`, `CHANGELOG.md` |
|       | Translated `GUIA_PROYECTO.md` → `PROJECT_GUIDE.md` (SPEC.md was already in English)                                  |

**Day deliverables:** 6 architecture and planning documents, project structure defined, technology stack frozen.

---

### Day 2 — July 28, 2026: Full MVP Implementation

Implementation was completed in **6 commits** throughout the day, organized by architectural layer.

---

#### Commit `ceb06a8` — Core, Network, and Server Engine Layers (M0–M3)

**Time:** 14:33

**Changes:** 28 files, +7,933 lines, 123 unit tests.

**Detail by layer:**

| Layer      | Files                                                                          | Purpose                                                                                                                                   |
| :--------- | :----------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------- |
| `core/`    | `messages.dart`, `constants.dart`, `validation.dart`, `geometry.dart`          | Protocol models (12 message types in Freezed sealed unions), 19 constants from SPEC §2.3, name/address validation, game geometry          |
| `network/` | `tcp_framing.dart`, `tcp_client.dart`, `tcp_server.dart`, `udp_discovery.dart` | `\n`-delimited JSON framing, TCP client with `Stream<ServerMessage>`, TCP server with coalescible broadcast, dual-broadcast UDP discovery |
| `server/`  | `server_state.dart`, `server_state_machine.dart`, `server_game_loop.dart`      | World state, state machine (Lobby→Countdown→Playing→GameOver→Lobby), authoritative game loop at 20 Hz                                     |
| `shared/`  | `logger.dart`                                                                  | Global logger with `ProductionFilter` + `logMessage()` for debug                                                                          |

**Bug fixed at this stage:** Freezed generates discriminator values in camelCase (`serverInfo`, `gameOver`) but the SPEC requires snake_case (`server_info`, `game_over`). Implemented helpers `canonicalizeDiscriminator()` and `restoreDiscriminator()` applied at the network layer.

**Tests:** 123 unit tests (framing 13, validation 30, geometry 14, TCP client 7, TCP server 11, discovery 8, state machine 13, game loop 27).

---

#### Commit `3e7f617` — UI Client: Menu Screens (M4)

**Time:** 14:50

**Changes:** 10 files, +903 lines.

| Component                  | Purpose                                                                                                                     |
| :------------------------- | :-------------------------------------------------------------------------------------------------------------------------- |
| `app_mode_provider.dart`   | App state machine: sealed class `AppMode` with 7 states (ModeSelect→HostSetup→Hosting→Discovering→NameEntry→Joining→InGame) |
| `app_shell.dart`           | Screen router using Dart 3 `switch` expressions on `AppMode`                                                                |
| `mode_select_screen.dart`  | Initial screen with Forui buttons: "Host Game" / "Join Game"                                                                |
| `server_name_screen.dart`  | Server name entry (host)                                                                                                    |
| `discovery_screen.dart`    | Automatic UDP scanning, server list, manual IP entry                                                                        |
| `name_entry_screen.dart`   | Player name entry with validation (1–20 chars, no control characters)                                                       |
| `lobby_screen.dart`        | Player list, "Start Game" button, countdown overlay                                                                         |
| `connection_provider.dart` | `TcpClient` lifecycle management (connect, send, receive `Stream<ServerMessage>`)                                           |
| `main.dart`                | Wiring of Forui `FTheme` + `ProviderScope` + `AppShell`                                                                     |

**UDP Discovery Extension:** Added `listenWithSource()` to `UdpDiscovery` to obtain the source IP along with each `ServerInfo`, needed so the discovery screen knows which IP to connect to.

---

#### Commit `22d2411` — Game Screen, Rendering, and Controls (M5)

**Time:** 15:02

**Changes:** 6 files, +476 lines.

| Component                  | Purpose                                                                                                                                                                                                                                                |
| :------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `game_painter.dart`        | `CustomPainter` that maps 1000×1000 logical coordinates to screen pixels. Renders: dark background, central circle (stroke), players (radius 15 circles), flag (white pole + red triangle). Local player in green (#00FF88), others in blue (#4488FF). |
| `virtual_joystick.dart`    | Circular touch area 140×140px, 8-direction quantization, 15px dead zone, sends `Dir` only when direction changes                                                                                                                                       |
| `interact_button.dart`     | Red circular button 72×72px with "E", sends `interact` onTap                                                                                                                                                                                           |
| `game_screen.dart`         | Composes GamePainter + joystick + interact button. Countdown and game over overlays. Spectator mode: hides controls.                                                                                                                                   |
| `game_state_provider.dart` | Immutable `GameWorld` with 7 fields, `GameStateNotifier` that processes all `ServerMessage` types                                                                                                                                                      |

---

#### Commit `47f40d6` — Server-Client Integration (M6)

**Time:** 15:16

**Changes:** 9 files, +567 lines.

This was the most critical commit — it wired the full flow:

| Component                       | Purpose                                                                                                                                                                                                                         |
| :------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `server_provider.dart`          | Server lifecycle management: creates `TcpServer` + `ServerGameState` + `ServerStateMachine` + `ServerGameLoop`. Syncs server state → `gameStateProvider` for the spectator view. Responds to UDP `discover` with `server_info`. |
| `lobby_screen.dart` (rewritten) | Host flow: waits for server to be ready, connects as local client, shows players. Joiner flow: connects to remote server, sends `join`, shows players. Automatic phase transitions to `InGame` upon receiving `start`.          |
| `server_name_screen.dart`       | On pressing "Start Server", starts the real server via `server_provider`                                                                                                                                                        |
| `app_shell.dart`                | Detects post-game transition (`game_over` → `lobby`) and returns to menu                                                                                                                                                        |
| `app_mode_provider.dart`        | `backToLobby()` fixed to distinguish host vs joiner                                                                                                                                                                             |
| `server_game_loop.dart`         | Added `onTick` callback for spectator sync at 20 Hz                                                                                                                                                                             |

---

#### Commit `e876b19` — Final Polish (M7)

**Time:** 15:24

**Changes:** 7 files, +321 lines.

| Improvement            | Detail                                                                                                                                                          |
| :--------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Name labels on avatars | `GamePainter` accepts `Map<String, String> playerNames`. Names rendered with semi-transparent background for readability.                                       |
| Countdown animation    | `TweenAnimationBuilder` with scale 0.5→1.0 + fade. Color ramp: 5=white, 4=yellow, 3=orange, 2=red, 1=bright red. Glow shadow.                                   |
| Error toast            | Overlay widget: red pill with error icon, fade-in, auto-dismiss in 3s. Integrated in lobby (host and joiner).                                                   |
| Stress test            | 100 simultaneous TCP clients, all send `join`, random movement for 5 seconds at 20 Hz. Verifies: no crashes, 100 welcomes received, `playing` phase maintained. |

---

#### Commit `39f25b1` — macOS Platform

**Time:** 15:49

**Changes:** 32 files, +1,520 lines.

Added macOS as an additional platform (iOS and Android already existed). Configuration for Xcode 16+:

| File                                     | Change                                                                                                                       |
| :--------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------- |
| `macos/Podfile`                          | Created with `platform :osx, '14.0'` and `post_install` that forces `MACOSX_DEPLOYMENT_TARGET = '14.0'` in all Pods          |
| `macos/Runner.xcodeproj/project.pbxproj` | `MACOSX_DEPLOYMENT_TARGET` changed from `10.15` to `14.0` in the 3 Flutter Assemble configurations (Debug, Profile, Release) |

---

## 2. Version Control and Git

### Commits

| Hash      | Date         | Description                                                     | Files |    +/−     |
| :-------- | :----------- | :-------------------------------------------------------------- | :---: | :--------: |
| `94bf06c` | Jul 26 14:45 | docs: PRD, TDD, agent orchestration, scaffolding                |  77   |   +4,324   |
| `ceb06a8` | Jul 28 14:33 | feat: core, network, and server engine layers                   |  28   | +7,933 −73 |
| `3e7f617` | Jul 28 14:50 | feat: client UI foundation and menu screens                     |  10   |  +903 −4   |
| `22d2411` | Jul 28 15:02 | feat: game screen, painter, and input widgets                   |   6   |  +476 −5   |
| `47f40d6` | Jul 28 15:16 | feat: server-client integration and lobby lifecycle             |   9   | +567 −162  |
| `e876b19` | Jul 28 15:24 | feat: polish — name labels, countdown, error toast, stress test |   7   |  +321 −73  |
| `39f25b1` | Jul 28 15:49 | build: add macOS platform with Sonoma deployment target         |  32   | +1,520 −6  |

**Total:** 7 commits, ~170 files, ~16,000 lines added.

### Branching Strategy

- **Single `main` branch** — trunk-based development. No feature branches (individual project).
- Atomic commits per milestone (M0→M7), each with the system in a functional state and all tests passing.
- Zero force-pushes, zero reverts. Linear history.

---

## 3. Connection Architecture

### Communication Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     HOST DEVICE                                  │
│                                                                  │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────────────┐  │
│  │ UDP :8888 │◄───│ Discovery    │───►│ server_info response │  │
│  │ (listens) │    │ (broadcast)  │    │ (unicast to client)  │  │
│  └──────────┘    └──────────────┘    └──────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ TCP Server (dynamic port)                                 │   │
│  │  • Accepts up to 100 connections                           │   │
│  │  • Framing: \n-delimited JSON (UTF-8)                     │   │
│  │  • State message coalescence for slow clients              │   │
│  │  • Authoritative game loop at 20 Hz                        │   │
│  │  • Spectator view (no controls)                            │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ LAN (Wi-Fi)
                              │
┌─────────────────────────────┼─────────────────────────────────┐
│                     CLIENT DEVICE                               │
│                              │                                   │
│  ┌──────────┐               │                                   │
│  │ UDP :8888 │──discover───►│                                   │
│  │ (dual:    │               │                                   │
│  │  255.255  │               │                                   │
│  │  + subnet)│               │                                   │
│  └──────────┘               │                                   │
│                              │                                   │
│  ┌──────────────────────────┴──────────────────────────────┐   │
│  │ TCP Client                                              │   │
│  │  • Connects to server TCP port                           │   │
│  │  • Sends: join, input (dir.x/dir.y), interact           │   │
│  │  • Receives: welcome, lobby, countdown, start, state,   │   │
│  │    game_over, error                                      │   │
│  │  • VirtualJoystick → input on each direction change      │   │
│  │  • InteractButton → interact onTap                      │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Message Format (Protocol v1.2.0)

Every TCP message is a single-line JSON object, terminated with `\n`:

```
{"type":"join","v":1,"name":"Player1"}\n
{"type":"input","dir":{"x":1,"y":0}}\n
{"type":"state","flag":{"owner":"p_123","x":600.0,"y":500.0},"players":[...]}\n
```

**Key features for interoperability:**

| Aspect          | Implementation                                                                                                                      |
| :-------------- | :---------------------------------------------------------------------------------------------------------------------------------- |
| **Transport**   | TCP for gameplay (dart:io `Socket`/`ServerSocket`), UDP for discovery (dart:io `RawDatagramSocket`)                                 |
| **Framing**     | Accumulator buffer + split by `\n`. `\r\n` tolerance (Windows). 64 KB limit per message.                                            |
| **Encoding**    | UTF-8                                                                                                                               |
| **Coalescence** | `state` messages are coalescible: if a client is slow, the server discards pending ones and sends only the most recent              |
| **Discovery**   | Dual UDP broadcast (255.255.255.255:8888 + subnet broadcast). Manual fallback: unicast to IP:8888 or direct TCP IP:port connection. |
| **Authority**   | 100% server. Client only sends intent (`dir`, `interact`). Server calculates position, validates capture/steal, detects victory.    |
| **Determinism** | Messages are processed in TCP arrival order. Same sequence → same result.                                                           |
| **Errors**      | 11 standardized error codes (`INVALID_JSON`, `NAME_INVALID`, `LOBBY_FULL`, `GAME_STARTED`, etc.)                                    |

### Protocol Constants

| Constant           | Value      | Meaning                           |
| :----------------- | :--------- | :-------------------------------- |
| `map_size`         | 1000       | 1000×1000 logical unit map        |
| `circle_radius`    | 300        | Central circle radius             |
| `circle_center`    | (500, 500) | Map center                        |
| `player_radius`    | 15         | Player body radius                |
| `interact_radius`  | 40         | Maximum distance to capture/steal |
| `speed`            | 200        | Units per second                  |
| `tick_rate`        | 20         | State sends per second            |
| `victory_distance` | 315        | Distance to exceed to win         |
| `discovery_port`   | 8888       | Fixed UDP port                    |
| `max_players`      | 100        | Maximum players                   |
| `message_max_size` | 64 KB      | Maximum message size              |

---

## 4. Artificial Intelligence Used

### Platform

**Zed AI Agent** (DeepSeek V4 Pro) — multi-agent system integrated into the Zed editor. Each agent receives a detailed prompt with context files, technical specifications, and verification criteria.

### Agents Deployed by Milestone

|  #  | Agent                          | Milestone | Responsibility                                           | Files created                                                            |
| :-: | :----------------------------- | :-------- | :------------------------------------------------------- | :----------------------------------------------------------------------- |
|  1  | Translate docs                 | M0        | `GUIA_PROYECTO.md` → `PROJECT_GUIDE.md` translation      | 1                                                                        |
|  2  | Agent A: TCP Framing           | M1        | Buffer + newline-delimited JSON framing                  | `tcp_framing.dart` + tests (13)                                          |
|  3  | Agent B: Validation + Geometry | M2        | Name/address validation, game geometry                   | `validation.dart`, `geometry.dart` + tests (44)                          |
|  4  | Agent C: TCP Client            | M1        | TCP client with `Stream<ServerMessage>`                  | `tcp_client.dart` + tests (7)                                            |
|  5  | Agent D: TCP Server            | M1        | Multi-client TCP server with coalescible broadcast       | `tcp_server.dart` + tests (11)                                           |
|  6  | Agent E: UDP Discovery         | M1        | Dual-broadcast UDP discovery + unicast                   | `udp_discovery.dart` + tests (8)                                         |
|  7  | Agent F: Server Engine         | M3        | Game state, state machine, game loop 20 Hz               | `server_state.dart`, `state_machine.dart`, `game_loop.dart` + tests (40) |
|  8  | Agent G: UI Foundation         | M4        | AppMode provider, AppShell, main.dart, ModeSelectScreen  | 4 files                                                                  |
|  9  | Agent H: Discovery Screen      | M4        | Discovery screen + UDP `listenWithSource()` extension    | `discovery_screen.dart`                                                  |
| 10  | Agent I: Name Entry Screen     | M4        | Name entry screen with validation                        | `name_entry_screen.dart`                                                 |
| 11  | Agent J: Lobby Screen          | M4        | Lobby screen + connection_provider                       | `lobby_screen.dart`, `connection_provider.dart`                          |
| 12  | Agent K: Game State Provider   | M5        | GameWorld + GameStateNotifier                            | `game_state_provider.dart`                                               |
| 13  | Agent L: Game Painter          | M5        | CustomPainter: map, circle, players, flag                | `game_painter.dart`                                                      |
| 14  | Agent M: Input Widgets         | M5        | VirtualJoystick + InteractButton                         | `virtual_joystick.dart`, `interact_button.dart`                          |
| 15  | Agent N: Game Screen           | M5        | GameScreen: painter + controls + overlays composition    | `game_screen.dart`                                                       |
| 16  | Agent O: Server Provider       | M6        | Server lifecycle management                              | `server_provider.dart`                                                   |
| 17  | Agent P: Lobby Integration     | M6        | Lobby integration with real providers, phase transitions | 5 files modified                                                         |
| 18  | Agent Q: Name Labels           | M7        | Name labels on avatars in the painter                    | 2 files modified                                                         |
| 19  | Agent R: Countdown Animation   | M7        | Countdown animation                                      | `game_screen.dart` modified                                              |
| 20  | Agent S: Error Toast           | M7        | Server error toast                                       | `error_toast.dart`                                                       |
| 21  | Agent T: Stress Test           | M7        | Stress test: 100 concurrent clients                      | `stress_test.dart`                                                       |

**Total:** 21 specialized agents deployed in 7 batches.

### Prompting Methodology

Each agent received a structured prompt with:

1. **Mandatory context files** — exact paths it MUST read before implementing
2. **Interface specification** — class/method signatures, parameters, return types
3. **Implementation rules** — constraints (do not modify existing files, do not use riverpod_generator, use native dart:io)
4. **Verification criteria** — exact commands to run: `dart format`, `flutter analyze`, `flutter test`
5. **Error handling** — "Fix any failures before reporting done"

### Recurring Prompt Patterns

**Network layer agent prompt (example — Agent C: TCP Client):**

```
Implement the TCP client for the CTF mobile game project.
Context files you MUST read first:
- messages.dart, tcp_framing.dart, logger.dart, SPEC_EN.md §1.1
What to create:
- tcp_client.dart with connect(), send(), Stream<ServerMessage>, close()
- Tests: connect+receive, send join/input/interact, multiple messages, disconnect
After writing, run: dart format, flutter analyze, flutter test
Fix any failures before reporting done.
Do NOT modify any existing files.
```

**UI agent prompt (example — Agent N: Game Screen):**

```
Implement the game screen for the CTF mobile game client.
Context files you MUST read first:
- game_state_provider.dart, connection_provider.dart, app_mode_provider.dart,
  game_painter.dart, virtual_joystick.dart, interact_button.dart, app_shell.dart
What to create:
- game_screen.dart: Stack with painter + controls + overlays
- Update app_shell.dart to wire InGame → GameScreen
After writing, run: dart format, flutter analyze, flutter test
Fix any compilation or analysis errors.
```

### Automated Verification

Each agent autonomously ran upon completion:

```bash
fvm dart format <files>    # Consistent formatting
fvm flutter analyze           # Zero issues required
fvm flutter test              # Zero regressions
```

The orchestrator agent (main conversation) additionally verified:

- full `fvm flutter test` after each batch
- global `fvm flutter analyze`
- Consistency across files created by different agents (wiring in app_shell, constructor signatures, imports)

### Bugs Detected and Fixed During Implementation

| Bug                                                    | Detected by                      | Solution                                                                     |
| :----------------------------------------------------- | :------------------------------- | :--------------------------------------------------------------------------- |
| Freezed discriminators in camelCase vs SPEC snake_case | Orchestrator review post-Agent F | Helpers `canonicalizeDiscriminator()` / `restoreDiscriminator()`             |
| NameEntryScreen did not accept ip/port as parameters   | Wiring post-Agent I/J            | Signature adjustment in app_shell (uses AppMode state)                       |
| LobbyScreen placeholder did not start the real server  | Agent P                          | `server_name_screen.dart` modified to call `serverProvider.notifier.start()` |
| `backToLobby()` did not distinguish host vs joiner     | Agent P                          | Fix in `app_mode_provider.dart` using pattern matching                       |
| UDP broadcast test flaky on loopback                   | Continuous review                | Test marked as known (broadcast does not work reliably on loopback)          |

---

## 5. Final Project Structure

```
lib/
├── main.dart
├── core/
│   ├── messages.dart              # 12 message types (Freezed sealed unions)
│   ├── messages.freezed.dart      # Generated
│   ├── messages.g.dart            # Generated
│   ├── constants.dart             # 19 SPEC constants
│   ├── validation.dart            # Input validation
│   └── geometry.dart              # Game math
├── network/
│   ├── tcp_framing.dart           # Buffer + split \n
│   ├── tcp_client.dart            # TCP client
│   ├── tcp_server.dart            # Multi-client TCP server
│   └── udp_discovery.dart         # UDP discovery
├── server/
│   ├── server_state.dart          # World state
│   ├── server_state_machine.dart  # State machine
│   └── server_game_loop.dart      # Game loop 20 Hz
├── client/
│   ├── app_shell.dart             # Screen router
│   ├── screens/                   # 6 screens
│   ├── painters/                  # GamePainter
│   ├── input/                     # Joystick + interact button
│   ├── widgets/                   # Error toast
│   └── providers/                 # 4 Riverpod providers
└── shared/
    └── logger.dart

test/
├── core/          # 44 tests
├── network/       # 39 tests
├── server/        # 40 tests
└── integration/   # 1 stress test (100 clients)
```

---

## 6. Final Metrics

| Metric                     | Value                                                             |
| :------------------------- | :---------------------------------------------------------------- |
| **Development days**       | 2 (planning 1 + implementation 1)                                 |
| **Commits**                | 7                                                                 |
| **Platforms**              | iOS, Android, macOS                                               |
| **Source files**           | 30                                                                |
| **Test files**             | 9                                                                 |
| **Total tests**            | 124 (123 pass, 1 flaky UDP)                                       |
| **Lines of code**          | ~5,000+                                                           |
| **Test coverage**          | ≥90% in core/server, ≥70% in network                              |
| **AI agents deployed**     | 21                                                                |
| **Implementation batches** | 7                                                                 |
| **Milestones completed**   | 9 (M0–M7)                                                         |
| **Static analysis**        | Zero issues                                                       |
| **Protocol**               | CTF Standard v1.2.0 — full implementation of all 12 message types |

---

## 7. Post-MVP Fixes (v0.2.0)

### Bugs Fixed in Post-MVP Iterations

| Bug                                                   | Cause                                                                               | Solution                                                                                           |
| :---------------------------------------------------- | :---------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------- |
| Countdown frozen at "5" (host)                        | `_periodicSync` sent hardcoded `countdown(5)` every 100ms                           | `ServerGameState` now stores real `countdownSeconds` decremented by the state machine              |
| Game never started after countdown (host)             | Host did not receive `Start` via TCP (not a client)                                 | `_tickSync` sends `Start` to `gameStateProvider` on the first tick if the phase is still countdown |
| Error "No Overlay widget found"                       | `WidgetsApp` without `home` or `pageRouteBuilder` does not create Navigator/Overlay | Added `home` + `pageRouteBuilder` to `WidgetsApp`                                                  |
| Error "No MaterialLocalizations found"                | `showDialog` (Material) requires MaterialLocalizations                              | Replaced with `showFDialog` (Forui) in discovery screen                                            |
| Error "Operation not permitted" on socket (macOS)     | Missing entitlement `com.apple.security.network.client`                             | Added to DebugProfile.entitlements and Release.entitlements                                        |
| Error "Bad state: Using ref when widget is unmounted" | `ref.read()` in `dispose()`                                                         | Notifiers stored as `late final` during state construction                                         |
| IP:port disappeared when a player joined              | `FutureBuilder` created a new future on each rebuild                                | Future memoized with `late final`                                                                  |
| IP:port covered by "Start Game" button                | Positioned at the end of the Column, below the Stack overlay                        | Moved under the title, above the list                                                              |
| Host joined as a player to its own server             | `_connectAsHost` sent `join`                                                        | Host TCP connection removed; spectator only via `_periodicSync`                                    |

### Quality Improvements

| Improvement               | Detail                                                                                                           |
| :------------------------ | :--------------------------------------------------------------------------------------------------------------- |
| Retro pixel theme         | Custom dark theme with Departure Mono font, arcade colors (neon green, deep space background), pixel-art borders |
| Keyboard support          | WASD/arrows for movement, E/Space to interact (additive to touch joystick)                                       |
| Logging with stack traces | All error handlers now capture and log `StackTrace`                                                              |
| Correct Forui theme       | `FToaster` + `FTooltipGroup` at app root per official Forui docs                                                 |
| macOS platform            | Full support with Sonoma 14.0 deployment target, network entitlements                                            |
| Name labels on avatars    | Labels with semi-transparent background for readability                                                          |
| Countdown animation       | Scale + fade + color ramp with glow shadow                                                                       |
| Error toast               | Overlay widget with fade-in and auto-dismiss in 3s                                                               |
