class_name GridMapData
extends RefCounted
## Grid position -> TileData lookup for a single level/test map. Levels
## will later load this from a data file instead of generate_empty().

var tiles: Dictionary = {}
var width: int = 0
var height: int = 0


func _init(p_width: int, p_height: int) -> void:
	width = p_width
	height = p_height


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
