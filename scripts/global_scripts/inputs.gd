extends Control

# INPUTS (AUTOLOAD #3)

# ..............................................................................

# TODO: deal with all inputs everywhere
# TODO: update world_inputs_enabled properly

var alt_pressed: bool = false

var world_inputs_enabled: bool = false
var action_inputs_enabled: bool = false
var zoom_inputs_enabled: bool = false

var sprint_toggle: bool = true

func _input(event: InputEvent) -> void:
	# ignore unrelated inputs
	if not (
			event.is_action(&"alt") or
			event.is_action(&"action") or
			event.is_action(&"full_screen") or
			event.is_action(&"1") or
			event.is_action(&"2") or
			event.is_action(&"3") or
			event.is_action(&"4")
	):
		return

	# handle inputs
	if event.is_action(&"alt"):
		accept_event()
		alt_pressed = event.is_pressed()
	elif Input.is_action_just_pressed(&"action"):
		action_input()
	elif Input.is_action_just_pressed(&"full_screen"):
		accept_event()
		Settings.toggle_fullscreen(
				DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED)

	# handle player swap inputs
	for index in Players.MAX_PARTY_SIZE:
		if Input.is_action_just_pressed(StringName(str(index + 1))):
			player_swap(index)
			break


func _unhandled_input(event: InputEvent) -> void:
	if not (world_inputs_enabled and event.is_action(&"esc")):
		return

	accept_event()

	if Input.is_action_just_pressed(&"esc"):
		if Entities.requesting_entities:
			Entities.end_entities_request()
		else:
			Global.global_ui(Global.Ui.NONE, Global.Ui.HOLO_DECK)


func action_input() -> void:
	if Players.main_player and action_inputs_enabled and not Entities.requesting_entities:
		accept_event()

		Players.main_player.action_input()


func player_swap(index: int) -> void:
	if (
			not is_instance_valid(Players.main_player) or
			not is_instance_valid(Players.party_bases[index]) or
			Players.main_player.party_index == index
	):
		return
	accept_event()
	Players.switch_main_player(Players.party_bases[index])


func toggle_text_box(to_enabled) -> void:
	world_inputs_enabled = to_enabled
	action_inputs_enabled = to_enabled
	zoom_inputs_enabled = to_enabled
