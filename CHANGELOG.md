# CHANGELOG.md

## [0.2.0] — 2026-07-28

### Added

- `lib/theme/pixel_theme.dart` — Custom dark pixel-game theme using Departure Mono font with arcade-inspired colors (neon green primary #00FF88, deep space background #0D0D1A), sharp pixel-art border radii
- Keyboard input: WASD/arrows for movement, E/Space for interact (additive to touch joystick)
- macOS platform support with Sonoma (14.0) deployment target
- Player name labels rendered above avatars in-game
- Countdown animation: scale + fade + color ramp (white→yellow→orange→red→bright red) with glow shadow
- Error toast widget with auto-dismiss and fade-in animation
- Host local IP display for manual connection
- Stack trace logging on all error paths

### Changed

- `main.dart`: Replaced MaterialApp with WidgetsApp + Forui's FTheme/FToaster/FTooltipGroup for proper dialog support
- Host is now spectator-only (removed TCP client self-connection and join message)
- `minPlayers` temporarily set to 1 for solo testing (SPEC says 2)
- Riverpod ref calls replaced with `late final` saved fields in LobbyScreen to prevent dispose-time errors
- `showDialog` (Material) → `showFDialog` (Forui) in discovery screen
- Material widgets replaced with Forui equivalents throughout (TextField→FTextField, AlertDialog→custom container, ListTile→Row, ScaffoldMessenger→showErrorToast, Icons→FLucideIcons)

### Fixed

- **Host countdown freeze:** ServerGameState now tracks `countdownSeconds`; `_periodicSync` syncs real seconds instead of hardcoded 5
- **Host game start:** `_tickSync` pushes `Start` to gameStateProvider on first tick if host's phase is stuck in countdown
- **macOS network permissions:** Added `com.apple.security.network.client` entitlement to both Debug and Release
- **Overlay/TextSelection errors:** WidgetsApp now includes `pageRouteBuilder` and uses `home` parameter for proper Navigator/Overlay
- **Dispose-time Riverpod error:** Provider notifiers saved as `late final` fields during construction
- **IP/port disappearing after join:** FutureBuilder memoized with `late final` future
- **IP/port hidden behind start button:** Moved to top of lobby under title
- **Logging completeness:** All error handlers now capture and log StackTrace
- **Back button:** Added to host lobby when waiting for players

## [0.1.0] — 2026-07-26

### Added

#### Core Layer

- `lib/core/messages.dart` — Freezed sealed unions for all 12 SPEC message types + enums + discriminator mapping helpers
- `lib/core/constants.dart` — All 19 protocol constants from SPEC §2.3
- `lib/core/validation.dart` — `ProtocolValidator`: name sanitization, dir validation, size/lobby checks
- `lib/core/geometry.dart` — `Geometry`: distance, clamping, spawn positions, victory checks, interaction range

#### Network Layer

- `lib/network/tcp_framing.dart` — Buffer accumulator with newline-delimited JSON framing
- `lib/network/tcp_client.dart` — TCP client with connect/send/Stream
- `lib/network/tcp_server.dart` — TCP server with broadcast + coalescible send
- `lib/network/udp_discovery.dart` — UDP discovery: dual broadcast + unicast fallback

#### Server Engine

- `lib/server/server_state.dart` — `ServerPlayer` + `ServerGameState`
- `lib/server/server_state_machine.dart` — Phase state machine with full lifecycle
- `lib/server/server_game_loop.dart` — 20 Hz authoritative game loop

#### Client UI

- 6 screens: mode select, server name, discovery, name entry, lobby, game
- GamePainter CustomPainter (map, circle, players, flag)
- VirtualJoystick (8-directional touch) + InteractButton
- 4 Riverpod providers (app mode, connection, game state, server)

#### Tests

- 124 tests across core, network, server, and integration layers

#### Documentation

- PRD, TDD, AGENTS.md, MEMORY.md, CURRENT_SPRINT.md, IMPLEMENTATION_PLAN.md

### Changed

- Updated `pubspec.yaml` with full dependency set
- Updated `.gitignore` with Flutter/Dart/IDE/OS rules

### Fixed

- Discriminator mapping: Freezed camelCase → SPEC snake_case via helper functions
