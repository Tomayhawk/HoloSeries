extends Consumable

const item_name: String = "Phoenix Burger"
const request_count: int = 1
const request_types: int = Entities.Type.PLAYERS_DEAD

func use_item(target_base: EntityBase) -> void:
	target_base.stats.revive(target_base.stats.max_health * 0.25)
