extends StaticBody2D

# INTERACTABLE BASE

# ..............................................................................

#region INITIAL

func _ready() -> void:
	set_process_input(false)
	Players.main_player_switched.connect(main_player_changed)

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# GUARD: world_inputs_disabled -> ignore input
	# INPUT: interact -> interact with object
	if event.is_action(&"interact"):
		Inputs.accept_event()
		if event.is_pressed() and not event.is_echo() and Inputs.world_inputs_enabled:
			get_parent().attempt_interact()

#endregion

# ..............................................................................

#region FUNCTIONS

# update input process when main player changes
func main_player_changed() -> void:
	set_process_input(self in Players.main_player.get_node(^"InteractionArea"
			).get_overlapping_bodies())


# triggered on npc entering/exiting player interaction area
func interaction_area(player_base: PlayerBase, status: bool) -> void:
	if player_base.is_main_player:
		set_process_input(status)
#endregion

# ..............................................................................
