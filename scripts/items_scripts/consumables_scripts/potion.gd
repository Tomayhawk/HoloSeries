extends Resource

const item_name: String = "Potion"
const request_count: int = 1
const request_types: int = Entities.Type.PLAYERS_ALIVE

func use_item(target_base: EntityBase) -> void:
	target_base.stats.update_health(200.0)
	Damage.damage_display(200, target_base.position, Damage.DamageTypes.HEAL)
