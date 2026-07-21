extends Node2D
## Placeholder gameplay scene. Has no mechanics of its own — it only exists
## to prove the pause flow (Escape -> PauseMenu -> Resume/Main Menu/Quit)
## works end to end. Replace with real gameplay once the jam starts.


func _ready() -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		GameManager.current_state = GameManager.GameState.PLAYING
