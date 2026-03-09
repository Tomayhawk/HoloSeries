extends Consumable

const ITEM_NAME: String = "Temp Kill Item"
const REQUEST_COUNT: int = 1
const REQUEST_TYPES: int = Entities.Type.PLAYERS_ALIVE

static func use_item(target_bases: EntityBase) -> void:
	target_bases.stats.update_health(-99999.9)
