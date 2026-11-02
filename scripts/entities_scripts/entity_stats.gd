class_name EntityStats
extends RefCounted

# ..............................................................................

#region CONSTANTS

# default stats
const DEFAULT_HEALTH: float = 200.0
const DEFAULT_MANA: float = 10.0
const DEFAULT_STAMINA: float = 150.0

const DEFAULT_MAX_SHIELD: float = 200.0

const DEFAULT_DEFENSE: float = 10.0
const DEFAULT_WARD: float = 10.0
const DEFAULT_STRENGTH: float = 10.0
const DEFAULT_INTELLIGENCE: float = 10.0
const DEFAULT_SPEED: float = 0.0
const DEFAULT_AGILITY: float = 0.0
const DEFAULT_CRIT_CHANCE: float = 0.05
const DEFAULT_CRIT_DAMAGE: float = 1.50

const DEFAULT_FORCE: float = 1.0
const DEFAULT_WEIGHT: float = 1.0
const DEFAULT_VISION: float = 1.0

# stats ceilings
const HEALTH_CEILING: float = 9999.0
const MANA_CEILING: float = 999.0
const STAMINA_CEILING: float = 999.0

const SHIELD_CEILING: float = 9999.0

const DEFENSE_CEILING: float = 999.0
const WARD_CEILING: float = 999.0
const STRENGTH_CEILING: float = 999.0
const INTELLIGENCE_CEILING: float = 999.0
const SPEED_CEILING: float = 255.0
const AGILITY_CEILING: float = 255.0

const FORCE_CEILING: float = 10.0
const WEIGHT_CEILING: float = 10.0
const VISION_CEILING: float = 10.0

# 1.0 to 0.5 knockback multiplier
const KNOCKBACK_SCALE: float = 0.5 / (WEIGHT_CEILING - DEFAULT_WEIGHT)
const KNOCKBACK_OFFSET: float = 1.0 + DEFAULT_WEIGHT * KNOCKBACK_SCALE
const KNOCKBACK_CEILING: float = 2.0

#endregion

# ..............................................................................

#region VARIABLES

var base: EntityBase = null
var level: int = 1

var alive: bool = true:
	set(value):
		alive = value

		if base is PlayerBase:
			if alive: # dead -> alive
				entity_types &= ~Entities.Type.PLAYERS_DEAD
				entity_types |= Entities.Type.PLAYERS_ALIVE
			else: # alive -> dead
				entity_types &= ~Entities.Type.PLAYERS_ALIVE
				entity_types |= Entities.Type.PLAYERS_DEAD

# bitmask for entity types (Entities.Type)
var entity_types: int = 0:
	set(value):
		if not is_instance_valid(base):
			entity_types = value
			return

		# add or remove from entity groups accordingly
		var changed_types: int = entity_types ^ value

		while changed_types > 0:
			# get rightmost remaining changed type in bitmask
			var type: int = changed_types & -changed_types

			if entity_types & type:
				base.remove_from_group(Entities.GROUP_NAME[type])
			else:
				base.add_to_group(Entities.GROUP_NAME[type])

			# remove resolved bit
			changed_types ^= type

		entity_types = value

# health, mana, stamina
var health: float = DEFAULT_HEALTH
var mana: float = DEFAULT_MANA
var stamina: float = DEFAULT_STAMINA

var base_health: float = DEFAULT_HEALTH
var base_mana: float = DEFAULT_MANA
var base_stamina: float = DEFAULT_STAMINA

var max_health: float = DEFAULT_HEALTH
var max_mana: float = DEFAULT_MANA
var max_stamina: float = DEFAULT_STAMINA

# shield
var shield: float = 0.0
var max_shield: float = DEFAULT_MAX_SHIELD

# stats
var defense: float = DEFAULT_DEFENSE
var ward: float = DEFAULT_WARD
var strength: float = DEFAULT_STRENGTH
var intelligence: float = DEFAULT_INTELLIGENCE
var speed: float = DEFAULT_SPEED
var agility: float = DEFAULT_AGILITY
var crit_chance: float = DEFAULT_CRIT_CHANCE
var crit_damage: float = DEFAULT_CRIT_DAMAGE

var base_defense: float = DEFAULT_DEFENSE
var base_ward: float = DEFAULT_WARD
var base_strength: float = DEFAULT_STRENGTH
var base_intelligence: float = DEFAULT_INTELLIGENCE
var base_speed: float = DEFAULT_SPEED
var base_agility: float = DEFAULT_AGILITY
var base_crit_chance: float = DEFAULT_CRIT_CHANCE
var base_crit_damage: float = DEFAULT_CRIT_DAMAGE

# force, weight, vision
var force: float = DEFAULT_FORCE
var weight: float = DEFAULT_WEIGHT
var vision: float = DEFAULT_VISION

var base_force: float = DEFAULT_FORCE
var base_weight: float = DEFAULT_WEIGHT
var base_vision: float = DEFAULT_VISION

#endregion

# ..............................................................................

#region STATS UPDATES

func update_health(value: float) -> void:
	# check if alive
	if not alive:
		return

	# update health
	health = clampf(health + value, 0.0, max_health)

	# add invincibility if damage dealt
	if value < 0.0:
		add_status(Entities.Status.INVINCIBLE)

	# handle death
	if health == 0.0:
		death()


func update_mana(value: float) -> void:
	if not alive:
		return
	mana = clampf(mana + value, 0.0, max_mana)


func update_stamina(value: float) -> void:
	if not alive:
		return
	stamina = clampf(stamina + value, 0.0, max_stamina)


func update_shield(value: float) -> void:
	if not alive:
		return
	shield = clampf(shield + value, 0.0, max_shield)

#endregion

# ..............................................................................

#region SET STATS

func reset_current_stats() -> void:
	# max health, mana, stamina
	max_health = base_health
	max_mana = base_mana
	max_stamina = base_stamina

	# current stats
	health = base_health
	mana = base_mana
	stamina = max_stamina

	defense = base_defense
	ward = base_ward
	strength = base_strength
	intelligence = base_intelligence
	speed = base_speed
	agility = base_agility
	crit_chance = base_crit_chance
	crit_damage = base_crit_damage

	force = base_force
	weight = base_weight
	vision = base_vision

	# shield
	shield = 0.0
	max_shield = base_health

#endregion

# ..............................................................................

#region DEATH & REVIVE

func knockback_multiplier() -> float:
	# GUARD: lightweight -> multiplier between 1.0x and 2.0x
	if weight < 1.0:
		return KNOCKBACK_CEILING - weight

	# multiplier between 1.0x and 0.5x
	return KNOCKBACK_OFFSET - weight * KNOCKBACK_SCALE


func death() -> void:
	# decrease effects timers
	for effect in effects.duplicate():
		if effect.remove_on_death:
			effect.remove_effect(self)

	alive = false
	stamina = max_stamina
	if base: base.death()

#endregion

# ..............................................................................

#region STATUS

var status: int = 0
var effects: Array[Effect] = []

func add_status(type: Entities.Status) -> Effect:
	var effect: Effect = Entities.STATUS_PRELOADS[type].new()
	if base:
		effect.effect_timer += base.stats_process_interval
	effects.append(effect)
	status |= type
	return effect


func update_status(type: Entities.Status) -> void:
	for effect in effects:
		if effect.effect_type == type:
			return
	status &= ~type


func remove_status(type: Entities.Status) -> void:
	for effect in effects.duplicate():
		if effect.effect_type == type:
			effect.remove_effect(self)


func clear_status() -> void:
	for effect in effects.duplicate():
		effect.remove_effect(self)


func has_status(type: Entities.Status) -> bool:
	return status & type

#endregion

# ..............................................................................
