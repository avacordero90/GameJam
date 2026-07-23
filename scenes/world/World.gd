extends Node2D
## Phase 2 scratch test map: layers obstacles and weighted tool spawns on
## top of the Phase 1 empty grid, to playtest the "cheap tools only run
## falls short" energy tension (see project_plan.md Day 2). No guards or
## real levels yet -- those land in later phases.

const GRID_WIDTH: int = 9
const GRID_HEIGHT: int = 9
const OBSTACLE_COUNT: int = 6
const OBSTACLE_MIN_STRENGTH: int = 1
const OBSTACLE_MAX_STRENGTH: int = 5

var _grid: GridMapData

@onready var player: Player = $Player
@onready var energy_label: Label = %EnergyLabel
@onready var inventory_label: Label = %InventoryLabel


func _ready() -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		GameManager.current_state = GameManager.GameState.PLAYING
	_grid = GridMapData.new(GRID_WIDTH, GRID_HEIGHT)
	_grid.generate_empty()
	var start_position := Vector2i(1, 1)
	_grid.scatter_obstacles(
		OBSTACLE_COUNT, OBSTACLE_MIN_STRENGTH, OBSTACLE_MAX_STRENGTH, start_position
	)
	player.setup(_grid, start_position)
	player.energy_changed.connect(_on_player_energy_changed)
	player.inventory_changed.connect(_on_player_inventory_changed)
	player.moved.connect(_on_player_moved)
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
			return Color.ORANGE_RED.lerp(
				Color.DARK_RED, tile.obstacle_strength / float(OBSTACLE_MAX_STRENGTH)
			)
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


func _on_player_moved(_new_grid_position: Vector2i) -> void:
	queue_redraw()
