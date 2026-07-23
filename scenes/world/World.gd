extends Node2D
## Day 3: loads Level 1 (Easy) from a data file (project_plan.md), adds
## guards that wander after each player turn, and checks the same-tile
## catch condition and the has_loot+exit win condition. Win/lose screens
## stay plain-text status labels for now -- real screens are Day 4 polish.

const LEVEL_PATH: String = "res://resources/levels/level_1_easy.tres"
const GUARD_SCENE: PackedScene = preload("res://scenes/world/Guard.tscn")

var _grid: GridMapData
var _guards: Array[Guard] = []

@onready var player: Player = $Player
@onready var energy_label: Label = %EnergyLabel
@onready var inventory_label: Label = %InventoryLabel
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		GameManager.current_state = GameManager.GameState.PLAYING
	var level: LevelData = load(LEVEL_PATH)
	_grid = GridMapData.from_level(level)
	player.setup(_grid, level.start_position)
	for guard_start in level.guard_start_positions:
		var guard: Guard = GUARD_SCENE.instantiate()
		add_child(guard)
		guard.setup(_grid, guard_start)
		_guards.append(guard)
	player.energy_changed.connect(_on_player_energy_changed)
	player.inventory_changed.connect(_on_player_inventory_changed)
	player.moved.connect(_on_player_turn)
	_on_player_energy_changed(player.energy)
	_on_player_inventory_changed(player.inventory)
	queue_redraw()


func _draw() -> void:
	for pos: Vector2i in _grid.tiles:
		var tile: GridTileData = _grid.tiles[pos]
		var rect := Rect2(Vector2(pos * Balance.TILE_SIZE), Vector2.ONE * Balance.TILE_SIZE)
		draw_rect(rect, _tile_color(tile))
		draw_rect(rect, Color.BLACK, false, 1.0)
	for pos: Vector2i in _grid.tools_on_ground:
		var center := Vector2(pos * Balance.TILE_SIZE) + Vector2.ONE * Balance.TILE_SIZE / 2.0
		draw_circle(center, Balance.TILE_SIZE * 0.2, Color.GOLD)


func _tile_color(tile: GridTileData) -> Color:
	match tile.type:
		GridTileData.TileType.WALL:
			return Color.DIM_GRAY
		GridTileData.TileType.OBSTACLE:
			var max_strength := float(Balance.TOOL_TIER_WEIGHTS.size())
			return Color.ORANGE_RED.lerp(Color.DARK_RED, tile.obstacle_strength / max_strength)
		GridTileData.TileType.LOOT:
			return Color.GOLDENROD
		GridTileData.TileType.EXIT:
			return Color.SEA_GREEN
		_:
			return Color.DARK_SLATE_GRAY


func _on_player_energy_changed(new_energy: int) -> void:
	energy_label.text = "Energy: %d" % new_energy


func _on_player_inventory_changed(inventory: Array) -> void:
	var text := "Tools: ["
	for i in range(inventory.size()):
		if i > 0:
			text += ", "
		var tool: ToolData = inventory[i]
		text += str(tool.tier)
	text += "]"
	inventory_label.text = text


func _on_player_turn(_new_grid_position: Vector2i) -> void:
	for guard in _guards:
		guard.maybe_move()
	queue_redraw()
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	if _is_player_caught():
		status_label.text = "Caught! Game over."
		GameManager.game_over()
	elif _is_player_won():
		status_label.text = "You win!"
		GameManager.game_over()


func _is_player_caught() -> bool:
	for guard in _guards:
		if guard.grid_position == player.grid_position:
			return true
	return false


func _is_player_won() -> bool:
	if not player.has_loot:
		return false
	var tile := _grid.get_tile(player.grid_position)
	return tile != null and tile.type == GridTileData.TileType.EXIT
