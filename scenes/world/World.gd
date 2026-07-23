extends Node2D
## Phase 1 scratch test map for validating the grid movement + energy
## deduction loop end to end (see project_plan.md Day 1). No obstacles,
## tools, or guards yet -- those land in later phases.

const GRID_WIDTH: int = 9
const GRID_HEIGHT: int = 9

var _grid: GridMapData

@onready var player: Node2D = $Player
@onready var energy_label: Label = %EnergyLabel


func _ready() -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		GameManager.current_state = GameManager.GameState.PLAYING
	_grid = GridMapData.new(GRID_WIDTH, GRID_HEIGHT)
	_grid.generate_empty()
	player.setup(_grid, Vector2i(1, 1))
	player.energy_changed.connect(_on_player_energy_changed)
	_on_player_energy_changed(player.energy)
	queue_redraw()


func _draw() -> void:
	for pos: Vector2i in _grid.tiles:
		var tile: GridTileData = _grid.tiles[pos]
		var color := Color.DIM_GRAY if tile.type == GridTileData.TileType.WALL else Color.DARK_SLATE_GRAY
		var rect := Rect2(Vector2(pos * Balance.TILE_SIZE), Vector2.ONE * Balance.TILE_SIZE)
		draw_rect(rect, color)
		draw_rect(rect, Color.BLACK, false, 1.0)


func _on_player_energy_changed(new_energy: int) -> void:
	energy_label.text = "Energy: %d" % new_energy
