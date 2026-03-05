extends Control

# TODO: deal with all inputs everywhere
# TODO: update world_inputs_enabled properly

var alt_pressed: bool = false

var world_inputs_enabled: bool = false
var action_inputs_enabled: bool = false
var zoom_inputs_enabled: bool = false

var sprint_hold: bool = true

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
	elif Input.is_action_just_pressed(&"1"):
		party_input(0)
	elif Input.is_action_just_pressed(&"2"):
		party_input(1)
	elif Input.is_action_just_pressed(&"3"):
		party_input(2)
	elif Input.is_action_just_pressed(&"4"):
		party_input(3)


func _unhandled_input(event: InputEvent) -> void:
	if not (world_inputs_enabled and event.is_action(&"esc")):
		return

	accept_event()

	if Input.is_action_just_pressed(&"esc"):
		if Entities.requesting_entities:
			Entities.end_entities_request()
		else:
			Global.add_global_child("HoloDeck", "res://user_interfaces/holo_deck.tscn")


func action_input() -> void:
	if Players.main_player and action_inputs_enabled and not Entities.requesting_entities:
		accept_event()

		Players.main_player.action_input()


func party_input(index: int) -> void:
	accept_event()

	# TODO: temporary code
	for player_base in get_tree().get_nodes_in_group(&"players"):
		if player_base.party_index == index:
			if not player_base.is_main_player:
				Players.switch_main_player(player_base)
			break


func toggle_text_box(to_enabled) -> void:
	world_inputs_enabled = to_enabled
	action_inputs_enabled = to_enabled
	zoom_inputs_enabled = to_enabled
