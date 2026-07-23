extends CanvasLayer
## Overlay shown whenever GameManager enters the PAUSED or GAME_OVER state.
## Lives inside World.tscn and keeps processing while the tree is paused so
## ui_cancel (Escape) can toggle pause/resume from a single place.

@onready var status_label: Label = %StatusLabel
@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	GameManager.state_changed.connect(_on_game_state_changed)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if GameManager.current_state == GameManager.GameState.PLAYING:
		GameManager.pause_game()
	elif GameManager.current_state == GameManager.GameState.PAUSED:
		GameManager.resume_game()


func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	var is_paused := new_state == GameManager.GameState.PAUSED
	var is_game_over := new_state == GameManager.GameState.GAME_OVER
	visible = is_paused or is_game_over
	resume_button.visible = is_paused
	status_label.text = "Game Over" if is_game_over else "Paused"


func _on_resume_pressed() -> void:
	GameManager.resume_game()


func _on_restart_pressed() -> void:
	GameManager.restart_game()


func _on_main_menu_pressed() -> void:
	GameManager.return_to_menu()


func _on_quit_pressed() -> void:
	GameManager.quit_game()
