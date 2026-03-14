extends Consumable

# POTION (CONSUMABLE)

# ..............................................................................

#region CONSTANTS

const ITEM_NAME: String = "Potion"
const REQUEST_COUNT: int = 1
const REQUEST_TYPES: int = Entities.Type.PLAYERS_ALIVE

#endregion

# ..............................................................................

#region FUNCTIONS

static func use_item(target_base: EntityBase) -> void:
	target_base.stats.update_health(200.0)
	Damage.damage_display(200, target_base.position, Damage.DamageTypes.HEAL)

#endregion

# ..............................................................................
