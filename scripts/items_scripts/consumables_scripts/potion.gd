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

static func use_item(target_base: EntityBase, id: int) -> void:
	if not target_base:
		return

	target_base.stats.update_health(200.0)
	Damage.damage_display(200, target_base.position, Damage.DamageTypes.HEAL)

	Inventory.decrement_consumable(id)


# target player with lowest health
static func auto_request() -> void:
	Entities.choose_entity(Entities.target_entity_by_stats(
			Entities.entities_available, &"health", false))

#endregion

# ..............................................................................
