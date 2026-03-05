extends Resource

const item_name: String = "Temp Kill Item"
const request_count: int = 1
const request_types: int = Entities.Type.PLAYERS_ALIVE

func use_item(target_bases: EntityBase) -> void:
	target_bases.stats.update_health(-99999.9)
