extends Node
## Central store for jam balance numbers, so gameplay tuning lives in one
## autoload instead of scattered across gameplay scripts.

const TILE_SIZE: int = 48
const START_ENERGY: int = 100
const MOVE_COST: int = 1
const SPAWN_INTERVAL: int = 5
const TOOL_TIER_WEIGHTS: Array[int] = [35, 25, 20, 12, 8]
const GUARD_MOVE_CHANCE: float = 0.65
## Tier 1-5 power color ramp, shared by tool pickups and obstacle strength.
const TIER_COLORS: Array[Color] = [
	Color.DODGER_BLUE, Color.LIME_GREEN, Color.GOLD, Color.ORANGE, Color.CRIMSON
]


func tier_color(tier: int) -> Color:
	return TIER_COLORS[clampi(tier, 1, TIER_COLORS.size()) - 1]
