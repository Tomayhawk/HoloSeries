extends Consumable

# PHOENIX BURGER (CONSUMABLE)

# ..............................................................................

#region CONSTANTS

const ITEM_NAME: String = "Phoenix Burger"
const REQUEST_COUNT: int = 1
const REQUEST_TYPES: int = Entities.Type.PLAYERS_DEAD

#endregion

# ..............................................................................

#region FUNCTIONS

static func use_item(target_base: EntityBase, id: int) -> void:
	if not target_base:
		return

	target_base.stats.revive(target_base.stats.max_health * 0.25)
	Inventory.decrement_consumable(id)


# target player with highest health
static func auto_request() -> void:
	Entities.choose_entity(Entities.target_entity_by_stats(
			Entities.entities_available, &"max_health", true))

#endregion

# ..............................................................................
