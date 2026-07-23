# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Godot 4.7 game jam project (GMTK Game Jam). GDScript only. Currently contains only boilerplate — no gameplay yet.

## Commands

There is no build step; this is a Godot project opened/run through the editor or `godot4` binary (path on this machine: `/home/ava/opt/Godot/godot4`, configured in `.vscode/settings.json`).

- Run the project: `godot4 --path .` (or open in the editor and press F5)
- Lint: `gdlint **/*.gd` (requires `gdtoolkit==4.*`, e.g. `pip install "gdtoolkit==4.*"`). This exact command runs in CI (`.github/workflows/gdlint.yml`) on every push/PR to main/master — run it before committing GDScript changes.
- No test suite exists yet.

If `gdtoolkit` can't be installed locally (no pip/root), hand-verify style against gdlint's rules instead of skipping the check: tabs-only indentation, and class-member ordering — `tool`, `class_name`, `extends`, docstring, signals, enums, constants, exported vars, public vars, private vars, onready vars, then built-in virtual methods (`_ready`, `_unhandled_input`, etc.) before other methods.

## Architecture

Two autoload singletons drive all cross-scene flow control; scenes should go through them rather than touching `SceneTree` or `get_tree().change_scene_to_file()` directly.

- **`GameManager`** (`autoload/GameManager.gd`) — owns `GameState` (`MENU`, `PLAYING`, `PAUSED`, `GAME_OVER`) and emits `state_changed` on every transition. Entry points: `start_game()`, `pause_game()`, `resume_game()`, `return_to_menu()`, `game_over()`, `quit_game()`. It also drives scene transitions (via `SceneManager`) for `start_game`/`return_to_menu`, and toggles `get_tree().paused`.
- **`SceneManager`** (`autoload/SceneManager.gd`) — thin wrapper around `change_scene_to_file`; unpauses the tree before switching and emits `scene_changed`. Don't call `get_tree().change_scene_to_file()` from scene scripts — call `SceneManager.change_scene(path)` instead.

Scene flow: `MainMenu.tscn` → (Start) → `World.tscn`, with `PauseMenu` as a `CanvasLayer` inside `World.tscn`. `PauseMenu` runs with `PROCESS_MODE_ALWAYS` so it can catch `ui_cancel` (Escape) while the tree is paused, and toggles its own visibility by listening to `GameManager.state_changed` rather than being shown/hidden imperatively. `World.gd` is currently a placeholder whose only job is to prove this pause loop works end to end — replace it with real gameplay once the jam theme is set.

When adding new scenes/mechanics, follow this pattern: scene scripts call into `GameManager`/`SceneManager` for state and navigation, and react to `state_changed` via signal connections rather than polling `GameManager.current_state` every frame.

## GDScript conventions (enforced by gdlint)

- Tabs for indentation.
- Typed GDScript throughout (`var health: int = 10`, typed signals, typed function signatures/returns).
- Class member ordering: `tool` → `class_name` → `extends` → docstring → signals → enums → constants → exported vars → public vars → private vars → onready vars → built-in virtual methods (`_ready`, `_unhandled_input`, ...) → other methods.
- Every `.gd` file has a matching `.gd.uid` sidecar (Godot 4.7 feature) — don't delete these when removing/renaming scripts without also handling the corresponding scene reference.

## Jam constraints (GMTK Game Jam)

- No AI-generated art, audio, or page content — disqualifying per jam rules. Code boilerplate prepared in advance is fine; content built specifically for the jam theme is not.
- Game must be playable on Windows or in-browser using keyboard/mouse only.
- Credit any third-party (licensed/public-domain) assets used.
