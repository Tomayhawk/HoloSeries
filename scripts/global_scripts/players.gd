extends Node2D

# GLOBAL PLAYERS MANAGER

# ..............................................................................

#region VARIABLES

var main_player: PlayerBase = null
var standby_characters: Array[PlayerStats] = []

@onready var camera: Camera2D = $Camera

#endregion

# ..............................................................................

#region FUNCTIONS

# TODO: need to update states and variables
func toggle_process(to_enabled: bool) -> void:
	main_player.velocity = Vector2.ZERO
	set_physics_process(to_enabled)

	if to_enabled:
		main_player.apply_movement(Input.get_vector(&"left", &"right", &"up", &"down", 0.2))


# switch main player to ally, and switch target ally to main player
func switch_main_player(next_main_player: PlayerBase) -> void:
	main_player.switch_to_ally()
	next_main_player.switch_to_main()


# update main player, add previous stats to standby, and update standby ui
func switch_standby_character(standby_index: int, party_index: int = -1) -> void:
	var target_party_member: PlayerBase = main_player

	# handle ally to standby switches
	if party_index != -1:
		for player in get_children():
			if player.party_index == party_index:
				target_party_member = player
				break

	if target_party_member.in_forced_move_state():
		return

	var prev_stats: PlayerStats = target_party_member.stats

	target_party_member.switch_character(standby_characters.pop_at(standby_index))
	standby_characters.insert(standby_index, prev_stats)
	Combat.ui.update_standby_ui(standby_index, prev_stats)

#endregion

# ..............................................................................
