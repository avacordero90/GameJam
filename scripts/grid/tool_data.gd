class_name ToolData
extends Resource
## A pickup that bypasses obstacles up to its tier's strength. Tier N
## bypasses obstacle strength <= N; using it grants back cost^2 energy.

var tier: int = 1
var cost: int = 1
var bypass_threshold: int = 1


static func for_tier(tier: int) -> ToolData:
	var tool := ToolData.new()
	tool.tier = tier
	tool.cost = tier
	tool.bypass_threshold = tier
	return tool


func reward() -> int:
	return cost * cost
