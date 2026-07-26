# Product Requirements Document: CTF Mobile MVP

## 1. Executive Summary & Vision

| Field               | Detail                          |
| :------------------ | :------------------------------ |
| **Product Name**    | Capture the Flag (CTF) — Mobile |
| **Version**         | MVP (1.0)                       |
| **Document Status** | Draft                           |
| **Author**          | CC8 2026 — Individual Project   |
| **Last Updated**    | 2026-07-26                      |

**Product Vision:** A zero-infra, LAN-party mobile game where up to 100 players compete in fast-paced rounds of capture the flag. One device hosts the server; others join via automatic LAN discovery. Every project in the CC8 class interoperates through a shared JSON-over-TCP protocol, turning the classroom into a live game network — no accounts, no cloud, no internet required.

---

## 2. Problem Statement & Impact Analysis

**Problem Definition:** Multiplayer mobile games typically require internet connectivity, cloud matchmaking servers, and user accounts. In a classroom or dorm LAN setting, this infrastructure is unavailable or impractical. Students need a game that works on a shared Wi-Fi network with zero setup — just open the app, discover nearby hosts, and play.

**User & Business Impact:**

- **Current friction:** Players must coordinate IP addresses manually, deal with NAT traversal, or use cloud services that introduce latency and account overhead.
- **Our solution:** One-tap LAN discovery via UDP broadcast. Automatic protocol negotiation. No accounts. No internet. The same app hosts or joins.
- **Class-level impact:** Interoperability with all CC8 projects means this isn't just one game — it's a shared network of compatible implementations, each with different tech stacks, all playing together.

---

## 3. Target Audience & Jobs to Be Done (JTBD)

**Primary Persona:** University student (18–25), owns an iPhone or Android phone, on a shared campus Wi-Fi network. Technically comfortable but expects consumer-app-level UX. Wants to jump into a quick game with friends between classes.

**Jobs to Be Done:**

| #      | Job Type   | Description                                                                           |
| :----- | :--------- | :------------------------------------------------------------------------------------ |
| JTBD-1 | Functional | Host a game on my phone so friends can join without any server setup                  |
| JTBD-2 | Functional | Discover and join nearby games in one tap without typing IP addresses                 |
| JTBD-3 | Functional | Compete in quick rounds (< 2 min each) with clear, fair rules enforced by the server  |
| JTBD-4 | Emotional  | Feel the thrill of stealing the flag at the last moment and escaping to victory       |
| JTBD-5 | Social     | Play together in the same room, trash-talk in person, no headsets or Discord required |

**Current Alternatives vs. Our Advantage:**

| Alternative                                      | Pain Point                                    | Our Advantage                                          |
| :----------------------------------------------- | :-------------------------------------------- | :----------------------------------------------------- |
| Cloud-based mobile games (Brawl Stars, Among Us) | Require internet + accounts; no LAN-only mode | Works 100% offline on local Wi-Fi                      |
| LAN PC games (Unreal Tournament, Quake)          | Not mobile; complex setup                     | Runs on phones, tap to host/join                       |
| Other CC8 classmate projects                     | Varying quality, different languages          | Flutter = native mobile UX + smooth rendering          |
| Manual IP connection                             | Error-prone, requires coordination            | Automatic UDP broadcast discovery with manual fallback |

---

## 4. User Stories & Acceptance Criteria

### Core Epic: End-to-End Gameplay

| #    | Story                                                                                                                                                   | Acceptance Criteria                                                                                                                                                                                                                                                                                                                                                                                        |
| :--- | :------------------------------------------------------------------------------------------------------------------------------------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| US-1 | **As a host,** I want to tap "Host Game" and have my phone become a server so others can join and play while I watch the action.                        | ✅ Server starts listening on an available TCP port and UDP:8888 for discovery.<br>✅ Server responds to `discover` with valid `server_info` JSON.<br>✅ Server transitions to `lobby` state and shows the player list screen.<br>✅ Host sees a spectator-only view during gameplay (all players visible, no controls).<br>✅ Host does NOT connect as a player (per project rules: server is view-only). |
| US-2 | **As a joiner,** I want to see a list of nearby games and join one with a single tap.                                                                   | ✅ Broadcasts `discover` to 255.255.255.255:8888 and subnet broadcast.<br>✅ Displays discovered servers with name, player count, and state (lobby/playing).<br>✅ Grayed-out servers show "In Game" with no join option.<br>✅ Manual "IP:port" entry fallback works for blocked broadcasts.                                                                                                              |
| US-3 | **As a player in lobby,** I want to see who else is waiting and get a countdown before the match starts.                                                | ✅ `lobby` messages update the player list in real time.<br>✅ When host taps "Start" (and ≥ 2 players), 5-second countdown displays: 5, 4, 3, 2, 1.<br>✅ Countdown aborts with return to lobby if players drop below 2.                                                                                                                                                                                  |
| US-4 | **As a player in game,** I want to move with a virtual joystick, see other players moving smoothly, and capture the flag by tapping an interact button. | ✅ 8-directional movement (virtual joystick or on-screen d-pad).<br>✅ All players' positions update at 20 tick/sec from server `state`.<br>✅ Flag rendered at center (free) or attached to portador (carried).<br>✅ Interact button sends `interact`; success/failure reflected in next `state`.<br>✅ Stealing: tap interact near the flag carrier → flag transfers instantly.                         |
| US-5 | **As the winner,** I want clear visual/audio feedback when I exit the circle with the flag and see a victory screen.                                    | ✅ Victory triggers when distance > 315 from center while carrying flag.<br>✅ All clients receive `game_over` with winner's ID.<br>✅ Victory screen shows winner name for 5 seconds.<br>✅ After 5s, all clients return to lobby without reconnecting.                                                                                                                                                   |

---

## 5. Functional Requirements & MoSCoW Prioritization

### Must Have (P0) — MVP Launch

| FR-#  | Feature                                                                           | User Value                                                        | Dependencies                                                 |
| :---- | :-------------------------------------------------------------------------------- | :---------------------------------------------------------------- | :----------------------------------------------------------- |
| FR-01 | Mode selection screen (Host / Join)                                               | Entry point for both server (spectator) and client (player) paths | None                                                         |
| FR-02 | UDP server discovery (broadcast + unicast fallback)                               | Joiners find hosts without knowing IPs                            | `dart:io` UDP socket, `SO_BROADCAST`                         |
| FR-03 | TCP game connection with newline-delimited JSON framing                           | Reliable, ordered message delivery for gameplay                   | `dart:io` TCP socket                                         |
| FR-04 | Player join with name validation (1–20 chars, trimmed, no control chars)          | Identity in lobby and game                                        | Freezed `join` message                                       |
| FR-05 | Lobby screen: player list, start button (host only), auto-start on ≥ 2 players    | Waiting room with transparency on who's connected                 | `lobby` message handling                                     |
| FR-06 | 5-second countdown before match start                                             | Builds anticipation, synchronizes all clients                     | `countdown` message, 1 Hz timer                              |
| FR-07 | Random spawn in ring R ∈ [350, 450] outside circle                                | Fair starting positions, no spawn camping                         | Server-side spawn logic                                      |
| FR-08 | 8-directional movement via virtual joystick/d-pad                                 | Core gameplay interaction                                         | `input` message, server integration at `speed=200`           |
| FR-09 | Flag capture (interact ≤ 40 units from free flag)                                 | Primary objective                                                 | `interact` message, server-side distance check               |
| FR-10 | Flag steal (interact ≤ 40 units from carrier)                                     | PvP tension, comeback mechanic                                    | `interact` message, no immunity period                       |
| FR-11 | Victory detection (portador crosses circle boundary outward, distance > 315)      | Win condition, match closure                                      | Server-side state machine tracking inside→outside transition |
| FR-12 | Game over screen (5s) → auto-return to lobby                                      | Seamless replay loop                                              | `game_over` message, `post_game_seconds=5`                   |
| FR-13 | Server-authoritative movement (client sends intent, server calculates position)   | Prevents cheating, ensures fairness                               | 20 tick/sec game loop                                        |
| FR-14 | CustomPainter game rendering (map, circle, players, flag)                         | Visual representation of game world                               | Logical→screen coordinate mapping                            |
| FR-15 | Server spectator view — host sees all players but cannot play (per project rules) | Host device serves as dedicated server + live scoreboard          | Server-side state replicated to host's own renderer          |
| FR-16 | Interoperability: all 12 protocol messages implemented per SPEC v1                | Class-wide compatibility                                          | Freezed message models, `toJson()`/`fromJson()`              |

### Should Have (P1) — Post-MVP Iteration

| FR-#  | Feature                                                           | Rationale for deferral                                     |
| :---- | :---------------------------------------------------------------- | :--------------------------------------------------------- |
| FR-17 | Player name labels rendered above avatars in-game                 | UX polish; requires text rendering on canvas               |
| FR-18 | Sound effects (capture, steal, victory, countdown beep)           | Audio asset pipeline adds scope; silent play is functional |
| FR-19 | Haptic feedback on interact/steal                                 | Nice-to-have mobile feel; depends on device support        |
| FR-20 | Server dashboard with connection stats (packets/sec, player list) | Useful for debugging but not player-facing                 |

### Could Have (P2) — Backlog

| FR-#  | Feature                                            | Rationale for deferral                                |
| :---- | :------------------------------------------------- | :---------------------------------------------------- |
| FR-21 | Player color customization                         | Cosmetic; requires protocol extension (v negotiation) |
| FR-22 | Match history / stats screen                       | Persistent state adds storage dependency              |
| FR-23 | Replay viewer (record and playback state messages) | Significant scope; fun but not core gameplay          |

### Out of Scope (Won't Have for MVP)

- **Internet/cloud multiplayer** — LAN-only by design (and by class requirement)
- **User accounts / authentication** — Protocol v1 has no auth; names are self-declared
- **Encryption (TLS/DTLS)** — Explicitly out of scope per SPEC §6.1
- **AI bots** — Only human players in MVP
- **In-game chat** — No chat messages in protocol v1; players talk in person
- **Persistent lobbies / matchmaking queues** — Server resets on disconnect

---

## 6. Non-Functional Requirements (NFRs)

### Performance

| Metric                     | Target                     | Measurement                                                   |
| :------------------------- | :------------------------- | :------------------------------------------------------------ |
| Server tick rate           | 20 Hz (50ms per tick)      | Consistent `Timer.periodic` execution                         |
| State broadcast latency    | < 16ms per client write    | Time from tick to socket write completion                     |
| Client render frame rate   | 60 FPS (16.67ms per frame) | Flutter DevTools frame timing                                 |
| Input-to-state round trip  | < 50ms on LAN              | Timestamp diff: input sent → state received with new position |
| Max concurrent connections | 100                        | Stress test with 100 mock TCP clients                         |
| Memory per connection      | < 1 MB                     | Process memory / active connections                           |
| App cold start             | < 2 seconds                | Time from tap to mode selection screen                        |

### Security & Privacy

| Requirement        | Details                                                                                                                               |
| :----------------- | :------------------------------------------------------------------------------------------------------------------------------------ |
| Input validation   | All client data treated as untrusted. `dir` values clamped to {-1, 0, 1}. Names sanitized (trim, control char removal, max 20 chars). |
| Message size limit | 64 KB max per message; oversized messages rejected with `MESSAGE_TOO_LARGE` and connection closed.                                    |
| Connection cap     | Max 100 TCP connections; excess rejected with `LOBBY_FULL`.                                                                           |
| No PII collection  | Only self-declared player names transmitted; no device IDs, accounts, or location data.                                               |
| LAN-only scope     | No internet-facing ports; game operates on local network only.                                                                        |

### Usability & Platform Support

| Requirement        | Details                                                                                                           |
| :----------------- | :---------------------------------------------------------------------------------------------------------------- |
| Platforms          | iOS 15+ (iPhone, iPad), Android 8+ (API 26)                                                                       |
| Form factors       | Phone and tablet (any orientation). Game view adapts to aspect ratio.                                             |
| Input methods      | Touch (virtual joystick + interact button). Optional: Bluetooth keyboard on iPad.                                 |
| Accessibility      | Minimum touch target 48×48dp for all interactive elements. Sufficient color contrast for flag/player distinction. |
| Offline resilience | App functions fully without internet; only LAN required.                                                          |

### Scalability

| Concern                 | Approach                                                                                                |
| :---------------------- | :------------------------------------------------------------------------------------------------------ |
| 100 concurrent clients  | Async I/O (`dart:io`), one `Stream` per connection, no per-client threads                               |
| State broadcast fan-out | `Future.wait` for parallel socket writes each tick; coalescence discards stale `state` for slow clients |
| Lobby player list       | Array in `lobby` message grows linearly; 100 names × 20 chars = 2 KB — well under 64 KB limit           |
| Long-running server     | No memory leaks: disconnected sockets cleaned up, stale timers cancelled                                |

---

## 7. Quality Standards & System Guardrails

### Code Quality

| Standard      | Requirement                                                                                                                                      |
| :------------ | :----------------------------------------------------------------------------------------------------------------------------------------------- |
| Type safety   | Dart strict mode enabled. No `dynamic` in protocol/model layer.                                                                                  |
| Null safety   | Dart 3.x sound null safety. All model fields explicitly nullable where protocol allows (e.g., `flag.owner`).                                     |
| Architecture  | Clear separation: `core/` (shared models, constants, validation), `network/` (socket layer), `server/` (game logic), `client/` (UI + rendering). |
| Linting       | `very_good_analysis`.                                                                                                                            |
| Test coverage | ≥ 80% on `core/` and `server/` logic. ≥ 60% on `network/` layer. Widget tests for all screens.                                                   |

### Production Restrictions — Zero Tolerance For:

- Placeholder text or hardcoded strings visible to users
- Silent exception swallowing (all errors logged or surfaced)
- Unvalidated protocol messages reaching game state
- UI freezes during network I/O (all I/O off main isolate via async/await)
- Hardcoded IP addresses or ports (except `discovery_port=8888` per spec)

---

## 8. UI/UX Architecture & Key User Flows

### Information Architecture (Screen Map)

```
App Launch
  └── ModeSelectScreen
        ├── [Host Game] → ServerNameEntry → Server starts → LobbyScreen (host/spectator)
        │     ├── Player list (live, host is NOT a player)
        │     ├── [Start Game] button (enabled when ≥ 2 players)
        │     ├── [Cancel] → back to ModeSelect
        │     ├── Countdown overlay (5s)
        │     └── GameScreen (spectator mode)
        │           ├── GameCanvas (all players visible, no controls)
        │           └── [End Game] button (force-stop, host only)
        │
        └── [Join Game] → DiscoveryScreen
              ├── Server list (auto-populated via UDP broadcast)
              │     └── Tap server → NameEntry → LobbyScreen (joiner)
              ├── [Manual Connect] → IP:port dialog → NameEntry → LobbyScreen (joiner)
              └── [Refresh] → re-sends discover broadcast

Countdown (5s overlay on LobbyScreen)
  └── GameScreen (player mode)
        ├── GameCanvas (CustomPainter: map, circle, players, flag)
        ├── VirtualJoystick (bottom-left)
        ├── InteractButton (bottom-right)
        └── PlayerNameLabels (optional, P1)

GameOverScreen (5s overlay on GameScreen)
  └── Auto-transition → LobbyScreen (all clients + host)
```

### Key User Flow: Join and Play

```
1. User opens app → sees "Host Game" / "Join Game" buttons
2. Taps "Join Game"
3. App broadcasts discover to LAN
4. List populates: "Sarah's Game (3/100, lobby)", "Server 2 (Playing)"
5. Taps "Sarah's Game"
6. Enters name "Player1" → taps "Join"
7. Lobby screen shows 4 players. Tapping sound effect (P1).
8. Host taps "Start" → countdown overlay: 5... 4... 3... 2... 1...
9. Game screen: spawned outside circle. Virtual joystick appears.
10. Moves toward center. Taps interact near flag → flag attaches.
11. Moves outward. Another player steals it → "Stolen!" feedback.
12. Chases, re-steals, exits circle → GAME OVER. Victory screen.
13. After 5s, returns to lobby. Ready for next round.
```

### Key User Flow: Host a Game (Spectator)

```
1. User opens app → taps "Host Game"
2. Enters server name: "My Game"
3. Server starts. UDP socket on 8888, TCP on random port.
4. Host sees lobby with 0 players (host is NOT a player).
5. Others join. Player list grows. Host sees names appear.
6. Host taps "Start" when ≥ 2 players connected.
7. Countdown. Game begins. Host sees spectator view — all players
   moving, flag status, but no joystick or interact button.
8. Host can tap "End Game" to force-stop the match if needed.
9. Game over → lobby. Host can start another round.
```

---

## 9. Success Metrics & OKRs (First Semester / Demo Period)

**North Star Metric:** Successful interop matches played — number of game rounds where at least one non-local player (different project) participated to completion.

| Category        | Metric                                                                    | Target                                   | Measurement                                  |
| :-------------- | :------------------------------------------------------------------------ | :--------------------------------------- | :------------------------------------------- |
| **Acquisition** | Classmates who successfully connected to our server                       | ≥ 10 unique projects                     | Logged join events with distinct `player_id` |
| **Activation**  | Joiner completes one full round (join → lobby → game → victory/game over) | ≥ 8 unique joiners                       | Server lifecycle tracking per connection     |
| **Retention**   | Lobby-to-lobby cycles per session (players don't leave after one game)    | ≥ 3 rounds per session                   | Server state machine transitions             |
| **Quality**     | Protocol conformance score                                                | 100% (all 12 message types interoperate) | Automated test suite against protocol spec   |
| **Performance** | Tick stability                                                            | < 1% missed ticks over a 5-min game      | Server tick timer drift measurement          |
| **UX**          | Time from app launch to in-game                                           | < 30 seconds                             | Manual timing in demo sessions               |

---

## 10. Constraints, Risks & Dependencies

### Constraints

| Constraint                           | Impact                                                                                       |
| :----------------------------------- | :------------------------------------------------------------------------------------------- |
| **No external networking libraries** | Must implement framing, buffering, and UDP broadcast manually with `dart:io`                 |
| **Protocol version locked at v=1**   | No custom extensions allowed; must conform to SPEC exactly                                   |
| **Single developer**                 | All features, tests, and docs by one person; scope must stay tight                           |
| **Mobile-only**                      | No desktop/web targets (though Flutter could; restricted by assignment scope)                |
| **Class-wide interop mandate**       | Must test against at minimum 3 other classmates' projects before demo                        |
| **No server timeout in v1**          | Idle clients stay connected indefinitely; server must handle "zombie" connections gracefully |

### Assumptions & Open Questions

| #   | Assumption / Question                                       | Status                                                                                                                                                                                      |
| :-- | :---------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| A-1 | All classmates will implement the same SPEC v1.2.0 exactly  | Assumed; confirmed by class agreement                                                                                                                                                       |
| A-2 | Classroom Wi-Fi supports UDP broadcast (not all routers do) | Risk; mitigated by manual IP fallback                                                                                                                                                       |
| A-3 | iOS allows UDP broadcast on App Store builds                | Verified: `SO_BROADCAST` available on iOS                                                                                                                                                   |
| A-4 | 100 concurrent players realistic on a single phone?         | Open: stress test needed. Server runs on mobile hardware.                                                                                                                                   |
| Q-1 | Should the host be able to play or spectator-only?          | ✅ Resolved: Host is spectator-only per project guide. Server device renders all players but provides no gameplay controls. To play, the host must join from a separate device as a client. |
| Q-2 | Landscape vs portrait for game screen?                      | Decision: support both. Game view is square (map 1000×1000); letterbox on wider screens.                                                                                                    |

### Risk Assessment

| Risk                                              | Type        | Probability | Impact                    | Mitigation                                                                 |
| :------------------------------------------------ | :---------- | :---------- | :------------------------ | :------------------------------------------------------------------------- |
| UDP broadcast blocked by router                   | Technical   | Medium      | High — no auto-discovery  | Manual IP:port fallback; broadcast to both 255.255.255.255 AND subnet      |
| Protocol mismatch with classmate's implementation | Interop     | Low         | Critical — grade affected | Automated message compliance test suite; test early with at least 3 peers  |
| Frame drops during 100-player broadcast           | Performance | Medium      | Medium — jittery movement | Coalescence of `state` messages; `Future.wait` for parallel writes         |
| iOS App Store sandbox blocks raw sockets          | Platform    | Low         | Critical — app won't run  | Test on physical iOS device early; `dart:io` supports iOS sockets          |
| Memory exhaustion from leaking socket connections | Technical   | Low         | High — server crash       | Explicit lifecycle management; stress test with connection churn           |
| Touch joystick feels unresponsive                 | UX          | Medium      | Medium — poor gameplay    | User testing; adjust dead zone and sensitivity; consider d-pad alternative |

---

## 11. MVP Definition of Done (DoD)

### Feature Completeness

- [ ] All 15 Must-Have (P0) functional requirements implemented
- [ ] Mode selection screen working on both iOS and Android
- [ ] Full protocol catalog (12 message types) parseable and serializable
- [ ] Server game loop running at 20 tick/sec with all validations
- [ ] Client renders all game state from server without local prediction

### Quality Assurance

- [ ] Unit tests: all message `toJson()`/`fromJson()` round-trip correctly
- [ ] Unit tests: victory condition, spawn positions, distance calculations
- [ ] Unit tests: name validation edge cases (empty, too long, control chars, trim)
- [ ] Unit tests: TCP framing (split messages, concatenated messages, `\r\n` tolerance)
- [ ] Unit tests: host spectator mode — server renders but host cannot send `input`/`interact`
- [ ] Widget tests: every screen renders without errors in all states (loading, data, error, empty)
- [ ] Integration test: server starts, client discovers, joins, plays one full round
- [ ] Stress test: 100 simultaneous TCP connections, 60-second game, no crashes
- [ ] Interop test: connect to ≥ 3 different classmates' projects
- [ ] Zero lint warnings. `flutter analyze` clean.

### Documentation

- [ ] PRD (this document) reviewed and approved
- [ ] Technical Design Document (TDD) completed (next step)
- [ ] API docs for internal modules (where non-obvious)
- [ ] README with setup instructions, build commands, and architecture overview
- [ ] Protocol conformance checklist (mapped against SPEC §2.3)

### Infrastructure & Release Readiness

- [ ] `pubspec.yaml` finalized with all dependencies pinned
- [ ] Build tested on physical iPhone and Android device
- [ ] `.gitignore` excludes build artifacts, IDE files, and secrets
- [ ] No hardcoded debug values in release mode
- [ ] App icon and name set (not Flutter default)
