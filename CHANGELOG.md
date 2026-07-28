# CHANGELOG.md

## [0.1.0] — 2026-07-26

### Added

- `docs/PRD.md` — Product Requirements Document (MVP scope, user stories, MoSCoW, NFRs, DoD)
- `docs/TDD.md` — Technical Design Document (architecture, component design, protocol contract, state management, network layer, game loop, rendering, testing strategy)
- `docs/PROJECT_GUIDE.md` — English translation of game rules and deliverable requirements (from GUIA_PROYECTO.md)
- `docs/SPEC.md` — Protocol specification v1.2.0 (original, in English)
- `AGENTS.md` — AI agent orchestration rules, documentation ownership matrix, guardrails
- `MEMORY.md` — Persistent project knowledge (vision, architecture, tech stack, domain terms, design decisions)
- `CURRENT_SPRINT.md` — Sprint 1 execution state (M0.1-M3 complete, M4 next)
- `IMPLEMENTATION_PLAN.md` — Milestone roadmap (M0 through M7, backlog, future ideas)
- `CHANGELOG.md` — This file

#### Core Layer

- `lib/core/messages.dart` — Freezed sealed unions for all 12 SPEC message types (`UdpMessage`, `ClientMessage`, `ServerMessage`), plus enums (`ServerState`, `GamePhase`, `ErrorReason` with 11 codes), and discriminator mapping helpers (`canonicalizeDiscriminator`, `restoreDiscriminator`)
- `lib/core/constants.dart` — All 19 protocol constants from SPEC §2.3 (non-configurable, private constructor)
- `lib/core/validation.dart` — `ProtocolValidator`: name sanitization, dir validation, size/lobby checks
- `lib/core/geometry.dart` — `Geometry`: distance, clamping, spawn positions, victory checks, interaction range

#### Network Layer

- `lib/network/tcp_framing.dart` — Buffer accumulator with newline-delimited JSON framing, `\r\n` tolerance, 64 KB limit enforcement via `TcpFramingException`
- `lib/network/tcp_client.dart` — TCP client: connect, send `ClientMessage`, broadcast `Stream<ServerMessage>`, automatic discriminator mapping
- `lib/network/tcp_server.dart` — TCP server: accept N clients, `ClientSession` wrapping, `broadcast()` + `broadcastCoalescible()` (per-session coalescence for `StateMsg`)
- `lib/network/udp_discovery.dart` — UDP discovery: dual broadcast (255.255.255.255 + subnet), unicast fallback, `server_info` listener, `discover` listener, platform-aware port reuse

#### Server Engine

- `lib/server/server_state.dart` — `ServerPlayer` + `ServerGameState`: world model, spawn, projections (`toStateMsg()`, `toLobbyMsg()`, `lobbyPlayers`, `gamePlayers`)
- `lib/server/server_state_machine.dart` — Phase state machine: handleJoin/Input/Interact/Disconnect, countdown chain with cancellation, game lifecycle (start → end → return to lobby)
- `lib/server/server_game_loop.dart` — 20 Hz authoritative tick: movement (with diagonal normalization), flag tracking, victory detection (inside→outside transition), interaction processing (capture/steal), coalescible state broadcast

#### Tests

- `test/core/validation_test.dart` — 30 tests (name validation, dir validation, size/lobby limits)
- `test/core/geometry_test.dart` — 14 tests (distance, clamping, spawn, victory, interaction range)
- `test/network/tcp_framing_test.dart` — 13 tests (single, concatenated, split, partial, Windows \r\n, size limits, clear)
- `test/network/tcp_client_test.dart` — 7 tests (connect/receive, send join/input/interact, multiple messages, disconnect, close reentrant)
- `test/network/tcp_server_test.dart` — 11 tests (start/stop, client connect/message, broadcast, coalescence, disconnect, sendTo, connectionCount)
- `test/network/udp_discovery_test.dart` — 8 tests (discover send/receive, version filtering, non-JSON discard, unicast)
- `test/server/state_machine_test.dart` — 13 tests (join validation, phase rejection, lobby full, countdown chain, abort, disconnect during game, flag reset)
- `test/server/game_loop_test.dart` — 27 tests (movement, diagonal normalization, clamping, capture, steal, victory transition, ordering)

### Changed

- Updated `pubspec.yaml` from bare Flutter scaffold to full dependency set (flutter_riverpod 3.2.1, forui ^0.24.3, freezed_annotation ^3.1.0, json_annotation ^4.12.0, logger ^2.7.0, riverpod_annotation 4.0.2, plus dev dependencies)
- Updated `.gitignore` with full Flutter/Dart/IDE/OS ignore rules (was only `.fvm/`)
- Created `lib/` directory structure (`core/`, `network/`, `server/`, `client/{screens,painters,input,providers}/`, `shared/`)

### Fixed

- **Discriminator mapping:** Freezed generates camelCase type values (`serverInfo`, `gameOver`) but SPEC v1.2.0 requires snake_case (`server_info`, `game_over`). Added `canonicalizeDiscriminator()` (incoming JSON) and `restoreDiscriminator()` (outgoing JSON) helpers applied at the network layer boundary, ensuring wire-format compliance without modifying generated code.
