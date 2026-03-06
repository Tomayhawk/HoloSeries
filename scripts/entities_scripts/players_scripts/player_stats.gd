class_name PlayerStats
extends EntityStats

# ..............................................................................

#region CONSTANTS

enum LevelKey { CAP, INCREMENT }

# movement
const DEFAULT_MOVE_SPEED: float = 140.0

const DEFAULT_DASH_MULTIPLIER: float = 8.0
const DEFAULT_DASH_STAMINA: float = 36.0
const DEFAULT_DASH_MIN_STAMINA: float = 28.0
const DEFAULT_DASH_TIME: float = 0.2

const DEFAULT_SPRINT_MULTIPLIER: float = 1.25
const DEFAULT_SPRINT_STAMINA: float = 24.0 # per second

# regeneration
const DEFAULT_MANA_REGEN: float = 0.25
const DEFAULT_STAMINA_REGEN: float = 16.0
const DEFAULT_FATIGUE_REGEN: float = 10.0

# experience requirements
const MAX_INT64: int = 0x7FFFFFFFFFFFFFFF
const BASE_XP_REQUIREMENT: int = 400

const XP_BRACKETS: Array[Dictionary] = [
	{ LevelKey.CAP: 5, LevelKey.INCREMENT: 125 },
	{ LevelKey.CAP: 10, LevelKey.INCREMENT: 150 },
	{ LevelKey.CAP: 20, LevelKey.INCREMENT: 225 },
	{ LevelKey.CAP: 40, LevelKey.INCREMENT: 350 },
	{ LevelKey.CAP: 70, LevelKey.INCREMENT: 500 },
	{ LevelKey.CAP: 100, LevelKey.INCREMENT: 800 },
	{ LevelKey.CAP: 150, LevelKey.INCREMENT: 1200 },
	{ LevelKey.CAP: 200, LevelKey.INCREMENT: 2000 },
	{ LevelKey.CAP: 250, LevelKey.INCREMENT: 3500 },
	{ LevelKey.CAP: 300, LevelKey.INCREMENT: 8000 },
]

#endregion

# ..............................................................................

#region STATS

# stats variables
var experience: int = 0
var experience_required: int = 400

# ultimate gauge variables
var ultimate_gauge: float = 0.0
var max_ultimate_gauge: float = 100.0

# nexus variables
var last_node: int = -1
var unlocked_nodes: Array[int] = []
var converted_nodes: Array[Vector2i] = [] # (index, type)

#endregion

# ..............................................................................

#region STATS UI

# stats bars
var health_bar: ProgressBar = null
var mana_bar: ProgressBar = null
var stamina_bar: ProgressBar = null
var shield_bar: ProgressBar = null

# combat ui nodes
var health_label: Label = null
var mana_label: Label = null
var ultimate_gauge_bar: ProgressBar = null

#endregion

# ..............................................................................

#region EQUIPMENTS

# equipments
var weapon: Weapon = null
var headgear: Headgear = null
var chestpiece: Chestpiece = null
var leggings: Leggings = null
var accessory_1: Accessory = null
var accessory_2: Accessory = null
var accessory_3: Accessory = null

#endregion

# ..............................................................................

#region ACTION VARIABLES

# movement
var move_speed: float = DEFAULT_MOVE_SPEED
var move_speed_modifier: float = 1.0

var dash_multiplier: float = DEFAULT_DASH_MULTIPLIER
var dash_stamina: float = DEFAULT_DASH_STAMINA
var dash_min_stamina: float = DEFAULT_DASH_MIN_STAMINA
var dash_time: float = DEFAULT_DASH_TIME

var sprint_multiplier: float = DEFAULT_SPRINT_MULTIPLIER
var sprint_stamina: float = DEFAULT_SPRINT_STAMINA # per second

var fatigue: bool = false

# regeneration
var mana_regen: float = DEFAULT_MANA_REGEN
var stamina_regen: float = DEFAULT_STAMINA_REGEN
var fatigue_regen: float = DEFAULT_FATIGUE_REGEN

# party
var last_action_cooldown: float = 0.0

#endregion

# ..............................................................................

#region PROCESS

func stats_process(process_interval: float) -> void:
	# regenerate mana
	if mana < max_mana:
		update_mana(mana_regen * process_interval)

	# update stamina
	if base.move_state == base.MoveState.SPRINT:
		update_stamina(-sprint_stamina * process_interval)
	elif base.move_state != base.MoveState.DASH and stamina < max_stamina:
		update_stamina((fatigue_regen if fatigue else stamina_regen) * process_interval)

	# decrease effects timers
	for effect in effects.duplicate():
		effect.effect_timer -= process_interval
		if effect.effect_timer <= 0.0:
			effect.effect_timeout(self)

#endregion

# ..............................................................................

#region HEALTH UPDATES

func update_health(value: float) -> void:
	super (value)

	# in party -> update health bar & label
	if base:
		update_health_display()


func update_health_display() -> void:
	# update health bar
	var bar_percentage: float = health / max_health
	health_bar.value = health
	health_bar.visible = health > 0.0 and health < max_health
	health_bar.modulate = (
			Color(0, 1, 0, 1) if bar_percentage > 0.5
			else Color(1, 1, 0, 1) if bar_percentage > 0.2
			else Color(1, 0, 0, 1)
	)

	# update combat ui label
	health_label.text = str(int(health))

#endregion

# ..............................................................................

#region MANA UPDATES

func update_mana(value: float) -> void:
	super (value)

	# in party -> update mana bar & label
	if base:
		update_mana_display()


func update_mana_display() -> void:
	# update mana bar
	mana_bar.value = mana
	mana_bar.visible = mana < max_mana

	# update combat ui label
	mana_label.text = str(int(mana))

#endregion

# ..............................................................................

#region STAMINA UPDATES

func update_stamina(value: float) -> void:
	super (value)

	# handle fatigue
	if stamina == 0:
		fatigue = true
		if base:
			base.fatigue_state()
	elif stamina == max_stamina:
		fatigue = false

	# in party -> update stamina bar
	if base:
		update_stamina_display()


func update_stamina_display() -> void:
	# update stamina bar
	stamina_bar.value = stamina
	stamina_bar.visible = stamina < max_stamina
	stamina_bar.modulate = Color(0.5, 0, 0, 1) if fatigue else Color(1, 0.5, 0, 1)

#endregion

# ..............................................................................

#region SHIELD UPDATES

func update_shield(value: float) -> void:
	super (value)

	# in party -> update shield bar
	if base:
		update_shield_display()


func update_shield_display() -> void:
	# update shield bar
	shield_bar.value = shield
	shield_bar.visible = shield > 0

#endregion

# ..............................................................................

#region ULTIMATE GAUGE UPDATES

func update_ultimate_gauge(value: float) -> void:
	if not alive:
		return

	ultimate_gauge = clamp(ultimate_gauge + value, 0, max_ultimate_gauge)

	# in party -> update ultimate gauge bar
	if base:
		update_ultimate_gauge_display()


func update_ultimate_gauge_display() -> void:
	# update ultimate gauge bar
	ultimate_gauge_bar.value = ultimate_gauge
	ultimate_gauge_bar.modulate.g = (130.0 - ultimate_gauge) / max_ultimate_gauge

#endregion

# ..............................................................................

#region LEVELS UPDATES

func update_experience(value: int) -> void:
	experience += value
	# check level up requirements
	while experience >= experience_required:
		experience -= experience_required
		level_up()


func level_up() -> void:
	level = clamp(level + 1, 1, 300) # cap level at 300
	set_experience_required()


# TODO: incomplete implementation
# initialize level
func initialize_level() -> void:
	experience_required = BASE_XP_REQUIREMENT
	var calc_level: int = 1
	var array_index: int = 0

	while experience > experience_required:
		while calc_level < level:
			if calc_level == XP_BRACKETS[array_index][LevelKey.CAP]:
				array_index += 1

			experience_required += XP_BRACKETS[array_index][LevelKey.INCREMENT]
			calc_level += 1

		if experience >= experience_required:
			experience -= experience_required
			level += 1


# store xp required for the next level
func set_experience_required() -> void:
	# max level = 300
	if level == 300:
		experience_required = MAX_INT64

	experience_required = BASE_XP_REQUIREMENT
	var calc_level: int = 1
	var array_index: int = 0

	while calc_level < level:
		if calc_level == XP_BRACKETS[array_index][LevelKey.CAP]:
			array_index += 1

		experience_required += XP_BRACKETS[array_index][LevelKey.INCREMENT]
		calc_level += 1

#endregion

# ..............................................................................

#region SET STATS

func load_character(character_data: Dictionary) -> void:
	# experience
	update_experience(character_data["experience"])

	# equipments
	weapon = null if character_data["weapon"] == -1 else Inventory.weapons[character_data["weapon"]]
	headgear = null if character_data["headgear"] == -1 else Inventory.armors[character_data["headgear"]]
	chestpiece = null if character_data["chestpiece"] == -1 else Inventory.armors[character_data["chestpiece"]]
	leggings = null if character_data["leggings"] == -1 else Inventory.armors[character_data["leggings"]]
	accessory_1 = null if character_data["accessory_1"] == -1 else Inventory.accessories[character_data["accessory_1"]]
	accessory_2 = null if character_data["accessory_2"] == -1 else Inventory.accessories[character_data["accessory_2"]]
	accessory_3 = null if character_data["accessory_3"] == -1 else Inventory.accessories[character_data["accessory_3"]]

	# nexus
	last_node = character_data["last_node"]
	unlocked_nodes.assign(character_data["unlocked_nodes"])
	converted_nodes.assign(character_data["converted_nodes"])


func set_stats() -> void:
	# TODO: update level and experience
	# TODO: update entity_types

	# nexus health, mana, defense, ward, strength, intelligence, speed, agility
	var nexus_stats: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

	# accumulate all nexus stats
	for unlocked_node in unlocked_nodes:
		var nexus_type: int = Global.nexus_types[unlocked_node]
		if nexus_type > 0 and nexus_type <= 8:
			nexus_stats[nexus_type - 1] += Global.nexus_qualities[unlocked_node]

	# set base stats from character constants and apply nexus modifications with clamping
	base_health = clamp(self.CHARACTER_HEALTH + nexus_stats[0], 1.0, 99999.0)
	base_mana = clamp(self.CHARACTER_MANA + nexus_stats[1], 1.0, 9999.0)
	base_defense = clamp(self.CHARACTER_DEFENSE + nexus_stats[2], 0.0, 1000.0)
	base_ward = clamp(self.CHARACTER_WARD + nexus_stats[3], 0.0, 1000.0)
	base_strength = clamp(self.CHARACTER_STRENGTH + nexus_stats[4], 0.0, 1000.0)
	base_intelligence = clamp(self.CHARACTER_INTELLIGENCE + nexus_stats[5], 0.0, 1000.0)
	base_speed = clamp(self.CHARACTER_SPEED + nexus_stats[6], 0.0, 255.0)
	base_agility = clamp(self.CHARACTER_AGILITY + nexus_stats[7], 0.0, 255.0)

	# stamina
	base_stamina = self.CHARACTER_STAMINA

	# crit stats
	base_crit_chance = self.CHARACTER_CRIT_CHANCE # 5% crit chance
	base_crit_damage = self.CHARACTER_CRIT_DAMAGE # 50% crit damage

	# weight, vision
	base_weight = 1.0
	base_vision = 1.0

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

	weight = base_weight
	vision = base_vision

	# TODO: to be updated

	var equipments = [weapon, headgear, chestpiece, leggings, accessory_1, accessory_2, accessory_3]

	for equipment in equipments:
		if equipment:
			equipment.set_stats(self)

	# TODO: manage constants
	move_speed = DEFAULT_MOVE_SPEED + (speed * 0.5) # max 268.0 speed
	dash_multiplier = DEFAULT_DASH_MULTIPLIER + (speed / (SPEED_CEILING * 0.5)) # max 10.0 multiplier
	dash_stamina = DEFAULT_DASH_STAMINA - (agility / (AGILITY_CEILING * 0.125)) # min 28.0 stamina per dash
	dash_min_stamina = DEFAULT_DASH_MIN_STAMINA - (agility / (AGILITY_CEILING * 0.125)) # min 20.0 stamina per dash

	dash_time = DEFAULT_DASH_TIME - (agility / (AGILITY_CEILING * 10.0)) # min 0.1s dash time
	sprint_multiplier = DEFAULT_SPRINT_MULTIPLIER + (speed / (SPEED_CEILING * 5.0)) # max 1.45 multiplier
	sprint_stamina = DEFAULT_SPRINT_STAMINA - (agility / (AGILITY_CEILING * 0.25)) # min 20.0 stamina per second

	mana_regen = DEFAULT_MANA_REGEN + (mana / 10000.0) # max 1.25 mana per second
	stamina_regen = DEFAULT_STAMINA_REGEN + (stamina / 25.0) # max 40.0 stamina per second
	fatigue_regen = DEFAULT_FATIGUE_REGEN + (stamina / 50.0) # max 25.0 stamina per second

	for equipment in equipments:
		if equipment:
			equipment.update_variable_stats(self)

	# TODO: update current stats based on effects

	# TODO: update max_shield based on stats

	# in party -> update base variables and nodes
	if base:
		set_base_variables()


func set_base_variables() -> void:
	# stats bars
	health_bar = base.get_node(^"HealthBar")
	mana_bar = base.get_node(^"ManaBar")
	stamina_bar = base.get_node(^"StaminaBar")
	shield_bar = base.get_node(^"ShieldBar")

	# combat ui nodes
	health_label = Combat.ui.health_labels[base.party_index]
	mana_label = Combat.ui.mana_labels[base.party_index]
	ultimate_gauge_bar = Combat.ui.ultimate_gauge_bars[base.party_index]

	# update display values
	update_display_values()


# update stats bars and labels
func update_display_values() -> void:
	# update max values
	health_bar.max_value = max_health
	mana_bar.max_value = max_mana
	stamina_bar.max_value = max_stamina
	shield_bar.max_value = max_shield
	ultimate_gauge_bar.max_value = max_ultimate_gauge

	# update stats displays
	update_health_display()
	update_mana_display()
	update_stamina_display()
	update_shield_display()
	update_ultimate_gauge_display()

#endregion

# ..............................................................................

#region DEATH

func death() -> void:
	fatigue = false
	super ()

#endregion

# ..............................................................................
