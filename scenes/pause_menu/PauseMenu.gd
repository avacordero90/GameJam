extends CanvasLayer
## Overlay shown whenever GameManager enters the PAUSED state. Lives inside
## World.tscn and keeps processing while the tree is paused so ui_cancel
## (Escape) can toggle pause/resume from a single place.

@onready var resume_button: Button = %ResumeButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
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
	visible = new_state == GameManager.GameState.PAUSED


func _on_resume_pressed() -> void:
	GameManager.resume_game()


func _on_main_menu_pressed() -> void:
	GameManager.return_to_menu()


func _on_quit_pressed() -> void:
	GameManager.quit_game()
