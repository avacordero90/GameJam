extends Node2D
## Grid-based player: moves one tile per input press along the four
## directional actions and deducts energy per move. Phase 1 only --
## obstacles, tools, and guards are not wired in yet.

signal energy_changed(new_energy: int)
signal moved(new_grid_position: Vector2i)

var grid_position: Vector2i = Vector2i.ZERO
var energy: int = Balance.START_ENERGY
var move_count: int = 0

var _grid: GridMapData


func setup(grid: GridMapData, start_position: Vector2i) -> void:
	_grid = grid
	grid_position = start_position
	position = Vector2(grid_position * Balance.TILE_SIZE)
	queue_redraw()


func _draw() -> void:
	var inset := 4.0
	var size := Vector2.ONE * (Balance.TILE_SIZE - inset * 2.0)
	draw_rect(Rect2(Vector2.ONE * inset, size), Color.SKY_BLUE)


func _unhandled_input(event: InputEvent) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	var direction := Vector2i.ZERO
	if event.is_action_pressed("ui_up"):
		direction = Vector2i.UP
	elif event.is_action_pressed("ui_down"):
		direction = Vector2i.DOWN
	elif event.is_action_pressed("ui_left"):
		direction = Vector2i.LEFT
	elif event.is_action_pressed("ui_right"):
		direction = Vector2i.RIGHT
	else:
		return
	_try_move(direction)


func _try_move(direction: Vector2i) -> void:
	var target := grid_position + direction
	if _grid == null or not _grid.is_walkable(target):
		return
	grid_position = target
	position = Vector2(grid_position * Balance.TILE_SIZE)
	move_count += 1
	energy -= Balance.MOVE_COST
	energy_changed.emit(energy)
	moved.emit(grid_position)
	if energy <= 0:
		GameManager.game_over()
