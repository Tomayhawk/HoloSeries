extends Consumable

const ITEM_NAME: String = "Potion"
const REQUEST_COUNT: int = 1
const request_types: int = Entities.Type.PLAYERS_ALIVE

func use_item(target_base: EntityBase) -> void:
	target_base.stats.update_health(200.0)
	Damage.damage_display(200, target_base.position, Damage.DamageTypes.HEAL)
