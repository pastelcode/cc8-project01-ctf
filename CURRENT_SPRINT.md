# CURRENT_SPRINT.md

## Sprint Objective

**Sprint 0: Foundation** — Scaffold the project, establish the build pipeline, and generate the protocol message layer. Zero gameplay yet. All code must compile, format cleanly, and pass analysis.

## Current Milestone

**Milestone 0.1: Project Scaffold & Build Pipeline**

## Active Tasks

| # | Task | Status | Owner |
| :-- | :--- | :----: | :---- |
| T-01 | Update `pubspec.yaml` with all dependencies (Riverpod, Freezed, Forui, logger, build_runner, etc.) | ⬜ TODO | AI |
| T-02 | Create the full `lib/` directory structure (`core/`, `network/`, `server/`, `client/`, `shared/`) | ⬜ TODO | AI |
| T-03 | Implement `lib/core/messages.dart` — Freezed sealed union for all 12 message types + enums (`ServerState`, `GamePhase`, `ErrorReason`) | ⬜ TODO | AI |
| T-04 | Implement `lib/core/constants.dart` — all protocol constants from SPEC §2.3 | ⬜ TODO | AI |
| T-05 | Implement `lib/shared/logger.dart` — configured Logger instance + `logMessage()` helper | ⬜ TODO | AI |
| T-06 | Run `build_runner` to generate `.freezed.dart` and `.g.dart` files | ⬜ TODO | AI |
| T-07 | Run `dart format` and `flutter analyze` — ensure zero errors | ⬜ TODO | AI |

## Completed Sprint Tasks

*(None yet — Sprint 0 has just begun.)*

## Next Recommended Task

**T-01: Update `pubspec.yaml`** — this unblocks all subsequent work.

## Current Blockers

*(None.)*

## Pending Engineering Decisions

| # | Decision | Status |
| :-- | :------- | :----- |
| D-01 | Forui version to pin (check latest compatible with Flutter 3.44.8+) | Pending |
| D-02 | Whether to use `riverpod_generator` for ALL providers or only some (manual `Notifier` for complex ones) | Pending |
| D-03 | Coordinate system for virtual joystick — absolute position or delta from center? | Pending (TDD specifies delta from center with dead zone) |

## Documents Updated This Sprint

- `docs/PRD.md` — created
- `docs/TDD.md` — created
- `AGENTS.md` — created
- `MEMORY.md` — created
- `CURRENT_SPRINT.md` — created
- `IMPLEMENTATION_PLAN.md` — created (this sprint)
- `CHANGELOG.md` — created (this sprint)

## Sprint Success Criteria

- [ ] All 7 tasks completed
- [ ] `dart format --set-exit-if-changed lib` passes
- [ ] `flutter analyze` passes with zero errors
- [ ] `build_runner` generates all `.freezed.dart` and `.g.dart` files without errors
- [ ] Project compiles (`flutter build` succeeds for at least one target)
