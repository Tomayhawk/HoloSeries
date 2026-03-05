extends Node2D

# ..............................................................................

#region CONSTANTS

const MANA_COST: float = 50.0
const BASE_DAMAGE: float = 5.0

const DAMAGE_TYPES: int = \
		Damage.DamageTypes.ENEMY_HIT | \
		Damage.DamageTypes.COMBAT | \
		Damage.DamageTypes.PHYSICAL | \
		Damage.DamageTypes.NO_CRITICAL

#endregion

# ..............................................................................

#region VARIABLES

var dice_results: Array[int] = []
var dice_damage := 0.0

@onready var caster_base: EntityBase = Players.main_player
@onready var interval_timer := %Interval

#endregion

# ..............................................................................

#region FUNCTIONS

func _ready() -> void:
	# disabled while selecting target
	set_physics_process(false)
	hide()

	Entities.entity_request_ended.connect(initiate_play_dice, CONNECT_ONE_SHOT)

	# request target entity
	Entities.request_entities(Entities.Type.ENEMIES_ON_SCREEN)

	if Entities.entities_available.is_empty():
		queue_free()
	# if alt is pressed, auto-aim closest enemy
	elif Inputs.alt_pressed:
		Entities.choose_entity(Entities.target_entity_by_distance(Entities.entities_available, caster_base.position, false))


func initiate_play_dice(chosen_nodes: Array[EntityBase]) -> void:
	var target_base: EntityBase = null
	var caster_stats: EntityStats = caster_base.stats

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
			if dice_results[-1] == 6: dice_damage *= 1.5

			# check for 5 dice duplicates
			if dice_results.count(dice_results[-1]) == 5: dice_damage *= 2

			# TODO: want to accelerate for each iteration
			interval_timer.start()
			Damage.combat_damage(dice_damage, DAMAGE_TYPES,
					caster_stats, target_base.stats)
			await interval_timer.timeout

	queue_free()


func entities_request_failed() -> void:
	queue_free()

#endregion

# ..............................................................................
