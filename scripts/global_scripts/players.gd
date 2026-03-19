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


func add_party_player(stats: PlayerStats, party_index: int) -> void:
	var player_base: Node = load(PLAYER_PATH).instantiate()
	player_base.initialize_player(stats, party_index)
	add_child(player_base)


func add_standby_character(stats: PlayerStats) -> void:
	Combat.ui.add_standby_button()
	standby_characters.append(stats)
	stats.reset_stats()


func recruit_character(stats: PlayerStats) -> void:
	# GUARD: party is full || has standby characters -> add character to standby
	if get_child_count() == MAX_PARTY_SIZE or not standby_characters.is_empty():
		add_standby_character(stats)
		return

	# find valid party index
	var party_index: int = 0
	for index in MAX_PARTY_SIZE:
		if not party_bases[index]:
			party_index = index
			break

	# add character to party
	add_party_player(stats, party_index)
	Players.party_bases[party_index].ally_teleport()

#endregion

# ..............................................................................
