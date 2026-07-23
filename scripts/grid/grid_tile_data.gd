class_name GridTileData
extends Resource
## Single grid cell: what kind of tile it is and, for obstacle tiles, how
## strong it is (used later to check which tool tiers can bypass it).

enum TileType { FLOOR, WALL, OBSTACLE, LOOT, EXIT }

@export var type: TileType = TileType.FLOOR
@export var obstacle_strength: int = 0
