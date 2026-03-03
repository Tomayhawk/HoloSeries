extends Node

# ..............................................................................

#region CONSTANTS

const DAMAGE_TYPES: int = \
		Damage.DamageTypes.PLAYER_HIT \
		| Damage.DamageTypes.HEAL \
		| Damage.DamageTypes.MAGIC \
		| Damage.DamageTypes.NO_CRITICAL \
		| Damage.DamageTypes.NO_MISS

const MANA_COST: float = 4.0

#endregion

# ..............................................................................

#region VARIABLES

var heal_percentage: float = 0.05

# TODO: need to dynamically allocate caster in case of ally/enemy casts (APPLIES TO ALL ABILITIES)
@onready var caster_base: EntityBase = Players.main_player
@onready var caster_stats: EntityStats = caster_base.stats

#endregion

# ..............................................................................

#region FUNCTIONS

func _ready() -> void:
	# request target entity
	Entities.entity_request_ended.connect(entity_chosen, CONNECT_ONE_SHOT)
	Entities.request_entities(Entities.Type.PLAYERS_ALIVE)

	# if alt is pressed, target player with lowest health
	if Inputs.alt_pressed:
		Entities.choose_entity(Entities.target_entity_by_stats(Entities.entities_available, &"health", false))


func entity_chosen(target_entity: EntityBase) -> void:
	# TODO: should add a variable for "player can cast spells"
	# heal if node chosen, caster is alive and caster has enough mana
	if target_entity and caster_stats.alive and caster_stats.mana >= MANA_COST:
		caster_stats.update_mana(-MANA_COST)
		# heal chosen node
		Damage.combat_damage(target_entity.stats.max_health * heal_percentage,
				DAMAGE_TYPES, caster_stats, target_entity.stats)

	queue_free()

#endregion

# ..............................................................................
