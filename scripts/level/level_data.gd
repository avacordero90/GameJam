class_name LevelData
extends Resource
## Hand-authored level layout: grid size, walls, obstacles, guard starts,
## loot/exit placement, and an optional visible starting tool. Levels are
## data files (.tres) built from this, not hardcoded scenes.

@export var width: int = 9
@export var height: int = 9
@export var start_position: Vector2i = Vector2i(1, 1)
@export var loot_position: Vector2i = Vector2i.ZERO
@export var exit_position: Vector2i = Vector2i.ZERO
@export var wall_positions: Array[Vector2i] = []
@export var obstacle_positions: Array[Vector2i] = []
@export var obstacle_strengths: Array[int] = []
@export var guard_start_positions: Array[Vector2i] = []
@export var starting_tool_position: Vector2i = Vector2i.ZERO
@export var starting_tool_tier: int = 0
