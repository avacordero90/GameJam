class_name Guard
extends Node2D
## Wanders the grid randomly: on each player turn, has a
## Balance.GUARD_MOVE_CHANCE chance to step one tile in a random direction
## that isn't a wall or obstacle. No player-noticing/chase AI (cut-first
## per project_plan.md) -- catching the player is purely same-tile luck.

const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

var grid_position: Vector2i = Vector2i.ZERO

var _grid: GridMapData


func setup(grid: GridMapData, start_position: Vector2i) -> void:
	_grid = grid
	grid_position = start_position
	position = Vector2(grid_position * Balance.TILE_SIZE)
	queue_redraw()


func _draw() -> void:
	var inset := 4.0
	var size := Vector2.ONE * (Balance.TILE_SIZE - inset * 2.0)
	draw_rect(Rect2(Vector2.ONE * inset, size), Color.CRIMSON)


func maybe_move() -> void:
	if randf() > Balance.GUARD_MOVE_CHANCE:
		return
	var valid_directions: Array[Vector2i] = []
	for direction in DIRECTIONS:
		if _grid.is_open_for_guard(grid_position + direction):
			valid_directions.append(direction)
	if valid_directions.is_empty():
		return
	grid_position += valid_directions[randi() % valid_directions.size()]
	position = Vector2(grid_position * Balance.TILE_SIZE)
	queue_redraw()
