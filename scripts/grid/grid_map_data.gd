class_name GridMapData
extends RefCounted
## Grid position -> TileData lookup for a single level/test map. Levels
## will later load this from a data file instead of generate_empty().

var tiles: Dictionary = {}
var tools_on_ground: Dictionary = {}
var width: int = 0
var height: int = 0


func _init(p_width: int, p_height: int) -> void:
	width = p_width
	height = p_height


static func from_level(level: LevelData) -> GridMapData:
	var grid := GridMapData.new(level.width, level.height)
	grid.generate_empty()
	for pos: Vector2i in level.wall_positions:
		grid.get_tile(pos).type = GridTileData.TileType.WALL
	for i in range(level.obstacle_positions.size()):
		var tile := grid.get_tile(level.obstacle_positions[i])
		tile.type = GridTileData.TileType.OBSTACLE
		tile.obstacle_strength = level.obstacle_strengths[i]
	grid.get_tile(level.loot_position).type = GridTileData.TileType.LOOT
	grid.get_tile(level.exit_position).type = GridTileData.TileType.EXIT
	if level.starting_tool_tier > 0:
		grid.tools_on_ground[level.starting_tool_position] = ToolData.for_tier(
			level.starting_tool_tier
		)
	return grid


func generate_empty(border_walls: bool = true) -> void:
	for x in range(width):
		for y in range(height):
			var pos := Vector2i(x, y)
			var tile := GridTileData.new()
			if border_walls and (x == 0 or y == 0 or x == width - 1 or y == height - 1):
				tile.type = GridTileData.TileType.WALL
			tiles[pos] = tile


func get_tile(pos: Vector2i) -> GridTileData:
	return tiles.get(pos)


func is_walkable(pos: Vector2i) -> bool:
	var tile := get_tile(pos)
	if tile == null:
		return false
	return tile.type != GridTileData.TileType.WALL


func is_open_for_guard(pos: Vector2i) -> bool:
	var tile := get_tile(pos)
	if tile == null:
		return false
	return tile.type != GridTileData.TileType.WALL and tile.type != GridTileData.TileType.OBSTACLE


func scatter_obstacles(count: int, min_strength: int, max_strength: int, exclude: Vector2i) -> void:
	var open := _open_floor_positions(exclude)
	open.shuffle()
	for i in range(mini(count, open.size())):
		var tile := get_tile(open[i])
		tile.type = GridTileData.TileType.OBSTACLE
		tile.obstacle_strength = randi_range(min_strength, max_strength)


func spawn_random_tool(exclude: Vector2i) -> void:
	var open := _open_floor_positions(exclude)
	if open.is_empty():
		return
	var pos: Vector2i = open[randi() % open.size()]
	tools_on_ground[pos] = ToolData.for_tier(_random_weighted_tier())


func _open_floor_positions(exclude: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for pos: Vector2i in tiles:
		var tile: GridTileData = tiles[pos]
		if tile.type != GridTileData.TileType.FLOOR:
			continue
		if pos == exclude or tools_on_ground.has(pos):
			continue
		result.append(pos)
	return result


func _random_weighted_tier() -> int:
	var weights := Balance.TOOL_TIER_WEIGHTS
	var total := 0
	for weight in weights:
		total += weight
	var roll := randi() % total
	var cumulative := 0
	for i in range(weights.size()):
		cumulative += weights[i]
		if roll < cumulative:
			return i + 1
	return weights.size()
