extends Consumable

const ITEM_NAME: String = "Reset Button"
const REQUEST_COUNT: int = 0
const request_types: int = 0

func use_item() -> void:
	for player_base in Global.get_tree().get_nodes_in_group(&"players_dead"):
		var heal_amount: float = player_base.stats.max_health
		player_base.stats.revive(heal_amount)
		Damage.damage_display(abs(heal_amount), player_base.position, Damage.DamageTypes.HEAL)
