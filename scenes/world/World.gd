extends Node2D
## Day 4: plays levels back to back -- clearing one loads the next with the
## player's carried-over energy/inventory instead of ending the run; only
## clearing the final level is a full win. Guards and grid state are
## rebuilt per level. Win/lose stays a plain-text status label per the
## cut-line default in project_plan.md.

const LEVEL_PATHS: Array[String] = [
	"res://resources/levels/level_1_easy.tres",
	"res://resources/levels/level_2_hard.tres",
	"res://resources/levels/level_3_expert.tres",
]
const GUARD_SCENE: PackedScene = preload("res://scenes/world/Guard.tscn")

var _grid: GridMapData
var _guards: Array[Guard] = []
var _level_index: int = 0

@onready var player: Player = $Player
@onready var energy_label: Label = %EnergyLabel
@onready var inventory_label: Label = %InventoryLabel
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		GameManager.current_state = GameManager.GameState.PLAYING
	player.energy_changed.connect(_on_player_energy_changed)
	player.inventory_changed.connect(_on_player_inventory_changed)
	player.moved.connect(_on_player_turn)
	_load_level(0)


func _draw() -> void:
	for pos: Vector2i in _grid.tiles:
		var tile: GridTileData = _grid.tiles[pos]
		var rect := Rect2(Vector2(pos * Balance.TILE_SIZE), Vector2.ONE * Balance.TILE_SIZE)
		draw_rect(rect, _tile_color(tile))
		draw_rect(rect, Color.BLACK, false, 1.0)
	for pos: Vector2i in _grid.tools_on_ground:
		var center := Vector2(pos * Balance.TILE_SIZE) + Vector2.ONE * Balance.TILE_SIZE / 2.0
		var tool: ToolData = _grid.tools_on_ground[pos]
		draw_circle(center, Balance.TILE_SIZE * 0.2, Balance.tier_color(tool.tier))


func _tile_color(tile: GridTileData) -> Color:
	match tile.type:
		GridTileData.TileType.WALL:
			return Color.DIM_GRAY
		GridTileData.TileType.OBSTACLE:
			return Balance.tier_color(tile.obstacle_strength)
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
		_advance_to_next_level()


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


func _advance_to_next_level() -> void:
	player.add_energy(Balance.level_clear_bonus(_level_index))
	if _level_index + 1 < LEVEL_PATHS.size():
		status_label.text = "Level %d cleared! Moving on..." % (_level_index + 1)
		_load_level(_level_index + 1)
	else:
		status_label.text = "Good job! You escaped with the loot -- you win!"
		GameManager.game_over()


func _load_level(index: int) -> void:
	_level_index = index
	for guard in _guards:
		guard.queue_free()
	_guards.clear()
	var level: LevelData = load(LEVEL_PATHS[index])
	_grid = GridMapData.from_level(level)
	player.has_loot = false
	player.setup(_grid, level.start_position, level.width, level.height)
	for guard_start in level.guard_start_positions:
		var guard: Guard = GUARD_SCENE.instantiate()
		add_child(guard)
		guard.setup(_grid, guard_start)
		_guards.append(guard)
	_on_player_energy_changed(player.energy)
	_on_player_inventory_changed(player.inventory)
	queue_redraw()
