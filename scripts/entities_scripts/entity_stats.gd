class_name EntityStats
extends Resource

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

const WEIGHT_CEILING: float = 100.0
const VISION_CEILING: float = 100.0

#endregion

# ..............................................................................

#region VARIABLES

var base: EntityBase = null
var level: int = 1

var alive: bool = true:
	set(value):
		alive = value

		if is_instance_valid(base) and base is PlayerBase:
			base.add_to_group(&"players_alive" if alive else &"players_dead")

var entity_types: int = 0 # bitmask for entity types (Entities.Type)

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

# weight, vision
var weight: float = 1.0
var vision: float = 1.0

var base_weight: float = 1.0
var base_vision: float = 1.0

#endregion

# ..............................................................................

#region STATS UPDATES

func update_health(value: float) -> void:
	# check if alive and not invincible for damage
	if not alive or (value < 0.0 and has_status(Entities.Status.INVINCIBLE)):
		return

	# update health
	health = clamp(health + value, 0.0, max_health)

	# add invincibility if damage dealt
	if value < 0.0:
		add_status(Entities.Status.INVINCIBLE)

	# handle death
	if health == 0.0:
		death()


func update_mana(value: float) -> void:
	if not alive: return
	mana = clamp(mana + value, 0.0, max_mana)


func update_stamina(value: float) -> void:
	if not alive: return
	stamina = clamp(stamina + value, 0.0, max_stamina)


func update_shield(value: float) -> void:
	if not alive: return
	shield = clamp(shield + value, 0.0, max_shield)

#endregion

# ..............................................................................

#region DEATH & REVIVE

func death() -> void:
	# decrease effects timers
	for effect in effects.duplicate():
		if effect.remove_on_death:
			effect.remove_effect(self)

	alive = false
	stamina = max_stamina
	if base: base.death()


func revive(value: float) -> void:
	alive = true
	update_health(value)
	if base: base.revive()

#endregion

# ..............................................................................

#region STATUS

var status: int = 0
var effects: Array[Resource] = []

func add_status(type: Entities.Status) -> Resource:
	var effect: Resource = Entities.STATUS_PRELOADS[type].new()
	effects.append(effect)
	status |= type
	return effect


func attempt_remove_status(type: Entities.Status) -> void:
	for effect in effects:
		if effect.effect_type == type:
			return
	status &= ~type


func force_remove_status(type: Entities.Status) -> void:
	for effect in effects.duplicate():
		if effect.effect_type == type:
			effect.remove_effect(self)
	status &= ~type


func has_status(type: Entities.Status) -> bool:
	return status & type


func reset_status() -> void:
	effects.clear()
	status = 0

#endregion

# ..............................................................................
