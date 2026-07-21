extends Node
## Tracks the overall game state and provides the high-level flow control
## (start / pause / resume / return to menu / quit) that every scene can
## call into instead of poking at the SceneTree directly.

signal state_changed(new_state: GameState)

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

var current_state: GameState = GameState.MENU


func start_game() -> void:
	current_state = GameState.PLAYING
	get_tree().paused = false
	state_changed.emit(current_state)
	SceneManager.change_scene("res://scenes/world/World.tscn")


func pause_game() -> void:
	if current_state != GameState.PLAYING:
		return
	current_state = GameState.PAUSED
	get_tree().paused = true
	state_changed.emit(current_state)


func resume_game() -> void:
	if current_state != GameState.PAUSED:
		return
	current_state = GameState.PLAYING
	get_tree().paused = false
	state_changed.emit(current_state)


func return_to_menu() -> void:
	current_state = GameState.MENU
	get_tree().paused = false
	state_changed.emit(current_state)
	SceneManager.change_scene("res://scenes/main_menu/MainMenu.tscn")


func game_over() -> void:
	current_state = GameState.GAME_OVER
	state_changed.emit(current_state)


func quit_game() -> void:
	get_tree().quit()
