extends Control

# TODO: deal with all inputs everywhere
# TODO: update world_inputs_enabled properly

var alt_pressed: bool = false

var world_inputs_enabled: bool = false
var action_inputs_enabled: bool = false
var zoom_inputs_enabled: bool = false

var sprint_hold: bool = true

func _input(event: InputEvent) -> void:
	# ignore all unrelated inputs
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

	else:
		#accept_event()

		# TODO: temporary code
		for i in range(1, 5):
			var action_name = str(i)
			if Input.is_action_just_pressed(action_name):
				for player in get_tree().get_nodes_in_group(&"players"):
					if player.party_index != i - 1:
						continue
					if not player.is_main_player:
						Players.switch_main_player(player)
					break
				break


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


func toggle_text_box(to_enabled) -> void:
	world_inputs_enabled = to_enabled
	action_inputs_enabled = to_enabled
	zoom_inputs_enabled = to_enabled
