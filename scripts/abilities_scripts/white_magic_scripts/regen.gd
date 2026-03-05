extends Node

# ..............................................................................

#region CONSTANTS

const DAMAGE_TYPES: int = \
		Damage.DamageTypes.PLAYER_HIT | \
		Damage.DamageTypes.HEAL | \
		Damage.DamageTypes.MAGIC | \
		Damage.DamageTypes.NO_CRITICAL | \
		Damage.DamageTypes.NO_MISS



#endregion

# ..............................................................................

#region VARIABLES

const MANA_COST: float = 20
const REGEN_COUNT: int = 7
const HEAL_PERCENTAGE: float = 0.02
# TODO: need to add stats multipliers

@onready var caster_base: EntityBase = Players.main_player

#endregion

# ..............................................................................

#region FUNCTIONS

func _ready() -> void:
	# request target entity
	Entities.entity_request_ended.connect(entity_chosen, CONNECT_ONE_SHOT)
	Entities.request_entities(Entities.Type.PLAYERS_ALIVE)

	# if alt is pressed, auto-aim player with lowest health
	if Inputs.alt_pressed:
		Entities.choose_entity(Entities.target_entity_by_stats(Entities.entities_available, &"health", false))


func entity_chosen(target_entity: EntityBase) -> void:
	# apply regen if node chosen, caster is alive and caster has enough mana
	if target_entity and caster_base.stats.alive and caster_base.stats.mana >= MANA_COST:
		caster_base.stats.update_mana(-MANA_COST)
		var effect: Resource = target_entity.stats.add_status(Entities.Status.REGEN)
		# 70 HP to 1470 HP (max at 7000 HP)
		effect.regen_settings(DAMAGE_TYPES, target_entity.stats,
				clamp(target_entity.stats.max_health * HEAL_PERCENTAGE, 10.0, 210.0),
				4.0, REGEN_COUNT, 0.8, 1.2)

	queue_free()

#endregion

# ..............................................................................
