class_name Player
extends Node2D
## Grid-based player: moves one tile per input press along the four
## directional actions, deducting energy per turn. Obstacles consume a
## sufficient tool from inventory (cheapest usable one) for a reward, or
## block the move if none is usable. Guards are not wired in yet.

signal energy_changed(new_energy: int)
signal inventory_changed(new_inventory: Array)
signal moved(new_grid_position: Vector2i)

var grid_position: Vector2i = Vector2i.ZERO
var energy: int = Balance.START_ENERGY
var move_count: int = 0
var inventory: Array[ToolData] = []
var has_loot: bool = false

var _grid: GridMapData

@onready var _camera: Camera2D = $Camera2D


func setup(
	grid: GridMapData, start_position: Vector2i, level_width: int, level_height: int
) -> void:
	_grid = grid
	grid_position = start_position
	position = Vector2(grid_position * Balance.TILE_SIZE)
	_camera.limit_left = 0
	_camera.limit_top = 0
	_camera.limit_right = level_width * Balance.TILE_SIZE
	_camera.limit_bottom = level_height * Balance.TILE_SIZE
	_camera.reset_smoothing()
	queue_redraw()


func add_energy(amount: int) -> void:
	energy += amount
	energy_changed.emit(energy)


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
	if _grid == null:
		return
	var target := grid_position + direction
	var tile := _grid.get_tile(target)
	if tile == null or tile.type == GridTileData.TileType.WALL:
		return
	if tile.type == GridTileData.TileType.OBSTACLE:
		var tool := _take_usable_tool(tile.obstacle_strength)
		if tool == null:
			energy -= Balance.MOVE_COST
			_advance_turn()
			return
		tile.type = GridTileData.TileType.FLOOR
		tile.obstacle_strength = 0
		energy += tool.reward()
		inventory_changed.emit(inventory)
	_move_to(target)
	energy -= Balance.MOVE_COST
	_advance_turn()


func _move_to(target: Vector2i) -> void:
	grid_position = target
	position = Vector2(grid_position * Balance.TILE_SIZE)
	if _grid.tools_on_ground.has(target):
		inventory.append(_grid.tools_on_ground[target])
		_grid.tools_on_ground.erase(target)
		inventory_changed.emit(inventory)
	var tile := _grid.get_tile(target)
	if tile.type == GridTileData.TileType.LOOT:
		has_loot = true
		tile.type = GridTileData.TileType.FLOOR


func _take_usable_tool(obstacle_strength: int) -> ToolData:
	var best: ToolData = null
	for tool: ToolData in inventory:
		if tool.bypass_threshold < obstacle_strength:
			continue
		if best == null or tool.tier < best.tier:
			best = tool
	if best != null:
		inventory.erase(best)
	return best


func _advance_turn() -> void:
	move_count += 1
	if move_count % Balance.SPAWN_INTERVAL == 0:
		_grid.spawn_random_tool(grid_position)
	energy_changed.emit(energy)
	moved.emit(grid_position)
	if energy <= 0:
		GameManager.game_over()
