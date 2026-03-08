extends Consumable

const ITEM_NAME: String = "Temp Kill Item"
const REQUEST_COUNT: int = 1
const request_types: int = Entities.Type.PLAYERS_ALIVE

func use_item(target_bases: EntityBase) -> void:
	target_bases.stats.update_health(-99999.9)
