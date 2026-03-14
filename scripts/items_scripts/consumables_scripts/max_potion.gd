extends Consumable

# MAX POTION (CONSUMABLE)

# ..............................................................................

#region CONSTANTS

const ITEM_NAME: String = "MAX Potion"
const REQUEST_COUNT: int = 0
const REQUEST_TYPES: int = 0

#endregion

# ..............................................................................

#region FUNCTIONS

static func use_item() -> void:
	for player_base in Players.get_children():
		if player_base.stats.alive:
			player_base.stats.update_health(99999.9)
			Damage.damage_display(99999, player_base.position, Damage.DamageTypes.HEAL)

#endregion

# ..............................................................................
