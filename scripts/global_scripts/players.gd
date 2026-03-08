extends Node2D

# PLAYERS (AUTOLOAD #5)

# ..............................................................................

#region CONSTANTS

const PLAYER_PATH: String = "res://entities/player_base.tscn"
const MAX_PARTY_SIZE: int = 4

const CHARACTER_PATH: String = "res://scripts/entities_scripts/players_scripts/character_scripts/%s.gd"
const CHARACTER_PATHS: Array[String] = [
	CHARACTER_PATH % "sora",
	CHARACTER_PATH % "azki",
	CHARACTER_PATH % "roboco",
	CHARACTER_PATH % "akirose",
	CHARACTER_PATH % "luna",
]

#endregion

# ..............................................................................

#region VARIABLES

var main_player: PlayerBase = null
var party_bases: Array[PlayerBase] = [null, null, null, null]
var standby_characters: Array[PlayerStats] = []

@onready var camera: Camera2D = $Camera

#endregion

# ..............................................................................

#region UTILITIES

# TODO: need to update states and variables
func toggle_process(to_enabled: bool) -> void:
	main_player.velocity = Vector2.ZERO
	set_physics_process(to_enabled)

	if to_enabled:
		main_player.apply_movement(Input.get_vector(&"left", &"right", &"up", &"down", 0.2))

#endregion

# ..............................................................................

#region SWITCH PLAYERS

# switch main player to ally, and switch target ally to main player
func switch_main_player(next_main_player: PlayerBase) -> void:
	main_player.switch_to_ally()
	next_main_player.switch_to_main()


# update main player, add previous stats to standby, and update standby ui
func switch_standby_character(standby_index: int, party_index: int = -1) -> void:
	var target_party_member: PlayerBase = main_player

	# handle ally to standby switches
	if party_index != -1:
		for player_base in get_children():
			if player_base.party_index == party_index:
				target_party_member = player_base
				break

	if target_party_member.in_forced_move_state():
		return

	var prev_stats: PlayerStats = target_party_member.stats

	target_party_member.switch_character(standby_characters.pop_at(standby_index))
	standby_characters.insert(standby_index, prev_stats)
	Combat.ui.update_standby_ui(standby_index, prev_stats)

#endregion

# ..............................................................................

#region RECRUIT CHARACTER

func load_player_stats(character_index: int, data: Dictionary) -> PlayerStats:
	var stats: PlayerStats = load(CHARACTER_PATHS[character_index]).new()
	stats.load_character(data)
	return stats


func add_party_player(stats: PlayerStats, party_index: int, is_main_player: bool = false) -> void:
	var player_base: Node = load(PLAYER_PATH).instantiate()
	player_base.is_main_player = is_main_player
	player_base.set_variables(stats, party_index)
	add_child(player_base)

	# TODO: incomplete implementation
	Combat.ui.character_infos_container_node.get_child(party_index).modulate.a = 1.0

	if is_main_player:
		main_player = player_base


func add_standby_character(stats: PlayerStats) -> void:
	standby_characters.append(stats)
	stats.set_stats()
	Combat.ui.add_standby_character(stats)


# TODO: broken
func recruit_character(stats: PlayerStats) -> void:
	if get_child_count() < MAX_PARTY_SIZE and standby_characters.is_empty():
		var base: PlayerBase = load(PLAYER_PATH).instantiate()
		add_child(base)
		base.stats = stats
		stats.base = base

		for index in party_bases.size():
			if not party_bases[index]:
				base.party_index = index

		stats.node_index = get_child_count() - 1 # TODO
		base.position = main_player.position + (25 * Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)))

		# TODO: make function for this
		Combat.ui.character_name_label_nodes[stats.node_index].text = stats.CHARACTER_NAME
		Combat.ui.players_info_nodes[stats.node_index].show()
		Combat.ui.ultimate_gauge_bar_nodes[stats.node_index].show()
		Combat.ui.shield_bar_nodes[stats.node_index].show()
	else:
		standby_characters.append(stats)
		stats.node_index = stats.get_index()

	stats.level = 1
	stats.base_health = stats.CHARACTER_HEALTH
	stats.base_mana = stats.CHARACTER_MANA
	stats.base_stamina = stats.CHARACTER_STAMINA

	stats.base_defense = stats.CHARACTER_DEFENSE
	stats.base_ward = stats.CHARACTER_WARD
	stats.base_strength = stats.CHARACTER_STRENGTH
	stats.base_intelligence = stats.CHARACTER_INTELLIGENCE
	stats.base_speed = stats.CHARACTER_SPEED
	stats.base_agility = stats.CHARACTER_AGILITY
	stats.base_crit_chance = stats.CHARACTER_CRIT_CHANCE
	stats.base_crit_damage = stats.CHARACTER_CRIT_DAMAGE

	stats.last_node = stats.CHARACTER_DEFAULT_UNLOCKED[1]
	stats.unlocked_nodes = stats.CHARACTER_DEFAULT_UNLOCKED
	Global.nexus_converted_nodes[3] = []

	var standby_button: Button = load("res://user_interfaces/user_interfaces_resources/combat_ui/standby_button.tscn").instantiate()
	Combat.ui.get_node(^"CharacterSelector/MarginContainer/ScrollContainer/CharacterSelectorVBoxContainer").add_child(standby_button)
	standby_button.pressed.connect(switch_standby_character.bind(standby_button.get_index()))
	standby_button.pressed.connect(Combat.ui.button_pressed)
	standby_button.mouse_entered.connect(Combat.ui._on_control_mouse_entered)
	standby_button.mouse_exited.connect(Combat.ui._on_control_mouse_exited)

	Combat.ui.standby_name_labels.append(standby_button.get_node(^"Name"))
	Combat.ui.standby_level_labels.append(standby_button.get_node(^"Level"))
	Combat.ui.standby_health_labels.append(standby_button.get_node(^"HealthAmount"))
	Combat.ui.standby_mana_labels.append(standby_button.get_node(^"ManaAmount"))

	# TODO: nexus

	stats.update_nodes()

	if stats.node_index == -1:
		Combat.ui.update_character_selector()

#endregion

# ..............................................................................
