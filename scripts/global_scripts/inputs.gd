extends Control

# INPUTS (AUTOLOAD #3)

# ..............................................................................

#region VARIABLES

var alt_pressed: bool = false

var world_inputs_enabled: bool = false
var action_inputs_enabled: bool = false
var zoom_inputs_enabled: bool = false

var sprint_on_release: bool = true

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# INPUT: accept events
	if event.is_action(&"full_screen"):
		accept_event()

	# INPUT: alt -> toggle alt_pressed variable
	if event.is_action(&"alt"):
		accept_event()
		alt_pressed = event.is_pressed()
	# INPUT: action -> handle action inputs
	elif event.is_action_pressed(&"action"):
		action_input()
	# INPUT: full_screen -> toggle fullscreen
	elif event.is_action_pressed(&"full_screen"):
		Settings.toggle_fullscreen(
				DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED)
	# INPUT: 1, 2, 3, 4 -> swap main player with player on target party index
	elif event.is_action(&"1"):
		player_swap(event, 0)
	elif event.is_action(&"2"):
		player_swap(event, 1)
	elif event.is_action(&"3"):
		player_swap(event, 2)
	elif event.is_action(&"4"):
		player_swap(event, 3)


func _unhandled_input(event: InputEvent) -> void:
	# GUARD: world inputs disabled -> ignore input
	# INPUT: esc -> end entities request || open holo deck
	if event.is_action_pressed(&"esc") and world_inputs_enabled:
		accept_event()
		if Entities.requesting_entities:
			Entities.end_entities_request()
		else:
			Global.global_ui(Global.Ui.NONE, Global.Ui.HOLO_DECK)

#endregion

# ..............................................................................

#region INPUT FUNCTIONS

func action_input() -> void:
	# GUARD: main player doesn't exist || action inputs disabled -> ignore input
	# GUARD: requesting entities -> ignore input
	if (
			is_instance_valid(Players.main_player)
			and action_inputs_enabled
			and not Entities.requesting_entities
	):
		accept_event()
		Players.main_player.action_input()


func player_swap(event: InputEvent, index: int) -> void:
	accept_event()

	# GUARD: main player doesn't exist || target player doesn't exist -> ignore input
	# GUARD: target is main player -> ignore input
	if (
			event.is_pressed()
			and is_instance_valid(Players.main_player)
			and is_instance_valid(Players.party_bases[index])
			and Players.main_player.party_index != index
	):
		Players.switch_main_player(Players.party_bases[index])

#endregion

# ..............................................................................

#region UTILITIES

func toggle_world_inputs(to_enabled: bool) -> void:
	world_inputs_enabled = to_enabled
	action_inputs_enabled = to_enabled
	zoom_inputs_enabled = to_enabled

#endregion

# ..............................................................................
