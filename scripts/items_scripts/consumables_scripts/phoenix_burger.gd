extends Consumable

const ITEM_NAME: String = "Phoenix Burger"
const REQUEST_COUNT: int = 1
const request_types: int = Entities.Type.PLAYERS_DEAD

func use_item(target_base: EntityBase) -> void:
	target_base.stats.revive(target_base.stats.max_health * 0.25)
