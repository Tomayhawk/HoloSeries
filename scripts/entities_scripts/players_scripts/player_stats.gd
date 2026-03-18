class_name PlayerStats
extends EntityStats

# ..............................................................................

#region ENUMS

enum LevelKey { LAST_LEVEL, INCREMENT, BASE_XP }

#endregion

# ..............................................................................

#region ACTION CONSTANTS

# movement
const MOVE_SPEED_BASE:			float = 140.0 # 140.0 to 260.0 speed
const MOVE_SPEED_SCALE:			float = 120.0 / SPEED_CEILING

# dash
const DASH_MULTIPLIER_BASE:		float = 8.0 # 8.0 to 10.0 multiplier
const DASH_MULTIPLIER_SCALE:	float = 2.0 / SPEED_CEILING

const DASH_STAMINA_BASE:		float = 36.0 # 36.0 to 28.0 stamina per dash
const DASH_STAMINA_SCALE:		float = 8.0 / AGILITY_CEILING

const DASH_TIME_BASE:			float = 0.2 # 0.2 to 0.1 seconds per dash
const DASH_TIME_SCALE:			float = 0.1 / AGILITY_CEILING

# dash stamina buffer
const DASH_STAMINA_BUFFER:		float = 8.0

# sprint
const SPRINT_MULTIPLIER_BASE:	float = 1.25 # 1.25 to 1.45 multiplier
const SPRINT_MULTIPLIER_SCALE:	float = 0.2 / SPEED_CEILING

const SPRINT_STAMINA_BASE:		float = 24.0 # 24.0 to 20.0 stamina per second
const SPRINT_STAMINA_SCALE:		float = 4.0 / AGILITY_CEILING

# regen
const MANA_REGEN_BASE:			float = 0.25 # 0.25 to 1.25 mana per second
const MANA_REGEN_SCALE:			float = 1.0 / MANA_CEILING

const STAMINA_REGEN_BASE:		float = 16.0 # 16.0 to 56.0 stamina per second
const STAMINA_REGEN_SCALE:		float = 40.0 / STAMINA_CEILING

const FATIGUE_REGEN_BASE:		float = 10.0 # 10.0 to 30.0 stamina per second
const FATIGUE_REGEN_SCALE:		float = 20.0 / STAMINA_CEILING

#endregion

# ..............................................................................

#region LEVEL CONSTANTS

# experience requirements
const MAX_INT64: int = 0x7FFFFFFFFFFFFFFF
const BASE_XP_REQUIREMENT: int = 400

const XP_BRACKETS: Array[Dictionary] = [
	{ LevelKey.LAST_LEVEL: 5, LevelKey.INCREMENT: 125, LevelKey.BASE_XP: 0 },
	{ LevelKey.LAST_LEVEL: 10, LevelKey.INCREMENT: 150, LevelKey.BASE_XP: 3_875 },
	{ LevelKey.LAST_LEVEL: 20, LevelKey.INCREMENT: 225, LevelKey.BASE_XP: 11_250 },
	{ LevelKey.LAST_LEVEL: 40, LevelKey.INCREMENT: 350, LevelKey.BASE_XP: 41_375 },
	{ LevelKey.LAST_LEVEL: 70, LevelKey.INCREMENT: 500, LevelKey.BASE_XP: 195_375 },
	{ LevelKey.LAST_LEVEL: 100, LevelKey.INCREMENT: 800, LevelKey.BASE_XP: 758_625 },
	{ LevelKey.LAST_LEVEL: 150, LevelKey.INCREMENT: 1200, LevelKey.BASE_XP: 1_911_375 },
	{ LevelKey.LAST_LEVEL: 200, LevelKey.INCREMENT: 2000, LevelKey.BASE_XP: 5_942_625 },
	{ LevelKey.LAST_LEVEL: 250, LevelKey.INCREMENT: 3500, LevelKey.BASE_XP: 13_993_875 },
	{ LevelKey.LAST_LEVEL: 300, LevelKey.INCREMENT: 8000, LevelKey.BASE_XP: 28_957_625 },
]

#endregion

# ..............................................................................

#region STATS

# stats variables
var experience: int = 0
var experience_required: int = 400
var accumulated_experience: int = 0

# ultimate gauge variables
var ultimate_gauge: float = 0.0
var max_ultimate_gauge: float = 100.0

# nexus variables
var last_node: int = -1
var unlocked_nodes: Array[int] = []
var converted_nodes: Array[Vector2i] = [] # (index, type)

# party
var last_action_cooldown: float = 0.0

#endregion

# ..............................................................................

#region ACTION STATS VARIABLES

# movement
var move_speed: float = MOVE_SPEED_BASE

# dash
var dash_multiplier: float = DASH_MULTIPLIER_BASE
var dash_stamina: float = DASH_STAMINA_BASE
var dash_time: float = DASH_TIME_BASE

# sprint
var sprint_multiplier: float = SPRINT_MULTIPLIER_BASE
var sprint_stamina: float = SPRINT_STAMINA_BASE

# regen
var mana_regen: float = MANA_REGEN_BASE
var stamina_regen: float = STAMINA_REGEN_BASE
var fatigue_regen: float = FATIGUE_REGEN_BASE

var fatigue: bool = false

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

	ultimate_gauge = clampf(ultimate_gauge + value, 0, max_ultimate_gauge)

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
	accumulated_experience += value

	# check level up requirements
	while experience >= experience_required:
		experience -= experience_required
		level = mini(level + 1, 300) # cap level at 300
		update_experience_required()


func update_experience_required() -> void:
	if level == 300:
		experience_required = MAX_INT64
		return

	# get current bracket
	var bracket_index: int = 0
	while level > XP_BRACKETS[bracket_index][LevelKey.LAST_LEVEL]:
		bracket_index += 1

	# get previous bracket last level
	var prev_last_level: int = 0
	if bracket_index != 0:
		prev_last_level = XP_BRACKETS[bracket_index - 1][LevelKey.LAST_LEVEL]

	# get position in current bracket
	var position_in_bracket: int = level - prev_last_level

	# increment required xp
	var xp_increment: int = XP_BRACKETS[bracket_index][LevelKey.BASE_XP]
	xp_increment += position_in_bracket * XP_BRACKETS[bracket_index][LevelKey.INCREMENT]

	experience_required = BASE_XP_REQUIREMENT + xp_increment

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


func reset_stats() -> void:
	reset_base_stats()
	reset_current_stats()
	reset_equipment_stats()
	reset_action_stats()
	reset_effect_stats()
	reset_base_variables()


# in party -> update base variables and nodes
func reset_base_stats() -> void:
	# get nexus stats
	const NEXUS_DATA: RefCounted = preload("res://scripts/holo_nexus_scripts/nexus_data.gd")
	var nexus_stats: Array[float] = NEXUS_DATA.set_nexus_stats(self)

	# set base stats with nexus stats and clamping
	base_health = minf(self.CHARACTER_HEALTH + nexus_stats[0], HEALTH_CEILING)
	base_mana = minf(self.CHARACTER_MANA + nexus_stats[1], MANA_CEILING)
	base_defense = minf(self.CHARACTER_DEFENSE + nexus_stats[2], DEFENSE_CEILING)
	base_ward = minf(self.CHARACTER_WARD + nexus_stats[3], WARD_CEILING)
	base_strength = minf(self.CHARACTER_STRENGTH + nexus_stats[4], STRENGTH_CEILING)
	base_intelligence = minf(self.CHARACTER_INTELLIGENCE + nexus_stats[5], INTELLIGENCE_CEILING)
	base_speed = minf(self.CHARACTER_SPEED + nexus_stats[6], SPEED_CEILING)
	base_agility = minf(self.CHARACTER_AGILITY + nexus_stats[7], AGILITY_CEILING)

	# set base stamina
	base_stamina = self.CHARACTER_STAMINA

	# set base crit stats
	base_crit_chance = self.CHARACTER_CRIT_CHANCE # 5% crit chance
	base_crit_damage = self.CHARACTER_CRIT_DAMAGE # 50% crit damage

	# set base force, weight, vision
	base_force = 1.0
	base_weight = 1.0
	base_vision = 1.0


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


func reset_equipment_stats() -> void:
	var equipments = [weapon, headgear, chestpiece, leggings, accessory_1, accessory_2, accessory_3]

	for equipment in equipments:
		if equipment:
			equipment.equip(self)


func reset_action_stats() -> void:
	# movement
	move_speed			= MOVE_SPEED_BASE			+ (speed * MOVE_SPEED_SCALE)

	# dash
	dash_multiplier		= DASH_MULTIPLIER_BASE		+ (speed * DASH_MULTIPLIER_SCALE)
	dash_stamina		= DASH_STAMINA_BASE			- (agility * DASH_STAMINA_SCALE)
	dash_time			= DASH_TIME_BASE			- (agility * DASH_TIME_SCALE)

	# sprint
	sprint_multiplier	= SPRINT_MULTIPLIER_BASE	+ (speed * SPRINT_MULTIPLIER_SCALE)
	sprint_stamina		= SPRINT_STAMINA_BASE		- (agility * SPRINT_STAMINA_SCALE)

	# regen
	mana_regen			= MANA_REGEN_BASE			+ (mana * MANA_REGEN_SCALE)
	stamina_regen		= STAMINA_REGEN_BASE		+ (stamina * STAMINA_REGEN_SCALE)
	fatigue_regen		= FATIGUE_REGEN_BASE		+ (stamina * FATIGUE_REGEN_SCALE)

	var equipments = [weapon, headgear, chestpiece, leggings, accessory_1, accessory_2, accessory_3]

	for equipment in equipments:
		if equipment:
			equipment.update_action_stats(self)


func reset_effect_stats() -> void:
	for effect in effects:
		effect.set_effect_stats(self)


func reset_base_variables() -> void:
	if not is_instance_valid(base):
		return

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

#region UTILITIES

func can_dash() -> bool:
	return not fatigue and stamina < dash_stamina - DASH_STAMINA_BUFFER

#endregion

# ..............................................................................

#region DEATH

func death() -> void:
	fatigue = false
	super ()

#endregion

# ..............................................................................
