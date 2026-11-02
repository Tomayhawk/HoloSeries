extends Area2D

# ..............................................................................

#region CONSTANTS

const MANA_COST: float = 50.0
const BASE_DAMAGE: float = 5.0

#endregion

# ..............................................................................

#region VARIABLES

var damage_types: int = (
		Damage.DamageTypes.ENEMY_TARGET
		| Damage.DamageTypes.PHYSICAL
		| Damage.DamageTypes.NO_CRITICAL
)

var dice_results: Array[int] = []
var dice_damage: float = 0.0

var caster_base: EntityBase = Players.main_player

@onready var interval_timer: Timer = %Interval

#endregion

# ..............................................................................

#region INITIAL

func _ready() -> void:
	# disabled while selecting target
	set_physics_process(false)
	hide()

	# TODO: should reconsider entire ability
	# TODO: use Area2D instead of request_entities

	# main player -> request target entity
	if caster_base == Players.main_player:
		Entities.entity_request_ended.connect(initiate_play_dice, CONNECT_ONE_SHOT)
		Entities.request_entities(Entities.Type.ENEMIES_ON_SCREEN, auto_request)

#endregion

# ..............................................................................

#region FUNCTIONS

# target enemy with shortest distance
func auto_request() -> void:
	Entities.choose_entity(Entities.target_entity_by_distance(
		Entities.entities_available, caster_base.position, false))


func initiate_play_dice(chosen_nodes: Array[EntityBase]) -> void:
	if chosen_nodes.is_empty():
		queue_free()
		return

	var target_base: EntityBase = null
	var caster_stats: EntityStats = caster_base.stats
	var interval: float = 2.0

	# TODO: redundant condition check
	# TODO: currently only attacks 1 enemy
	# check chosen entities
	if not chosen_nodes.is_empty():
		target_base = chosen_nodes[0]

	# check caster status and mana sufficiency
	if caster_stats.mana > MANA_COST and caster_stats.alive:
		caster_stats.update_mana(-MANA_COST)

		# roll 1 to 17 dice
		for i in (1 + (caster_stats.speed + caster_stats.agility) / 32):
			if not is_instance_valid(target_base) or not target_base.stats.alive:
				break

			dice_results.append(randi() % 7)
			dice_damage = BASE_DAMAGE / 2.0 * dice_results[-1]

			# double damage for each duplicate
			dice_damage *= 2 * dice_results.count(dice_results[-1])

			# check for "6"
			if dice_results[-1] == 6:
				dice_damage *= 1.5

			# check for 5 dice duplicates
			if dice_results.count(dice_results[-1]) == 5:
				dice_damage *= 2

			interval_timer.start(interval)
			interval *= 0.75

			Damage.combat_damage(dice_damage, damage_types,
					caster_stats, target_base.stats)

			await interval_timer.timeout

	queue_free()


func entities_request_failed() -> void:
	queue_free()

#endregion

# ..............................................................................
