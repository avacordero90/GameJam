extends Node
## Central store for jam balance numbers, so gameplay tuning lives in one
## autoload instead of scattered across gameplay scripts.

const TILE_SIZE: int = 48
const START_ENERGY: int = 20
const MOVE_COST: int = 1
const SPAWN_INTERVAL: int = 5
const TOOL_TIER_WEIGHTS: Array[int] = [35, 25, 20, 12, 8]
