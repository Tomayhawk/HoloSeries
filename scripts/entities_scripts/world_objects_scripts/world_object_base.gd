extends StaticBody2D

# WORLD OBJECT BASE (WORLD OBJECT)

# TODO: input process should reflect main player changes

# ..............................................................................

#region INITIAL

func _ready() -> void:
	set_process_input(false)

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# INPUT: accept events
	if event.is_action(&"interact"):
		Inputs.accept_event()

	# GUARD: world_inputs_disabled || interaction requirements not met -> ignore input
	# INPUT: interact -> interact with world object
	if (
			event.is_action_pressed(&"interact")
			and Inputs.world_inputs_enabled
			and get_parent().can_interact()
	):
		Inputs.accept_event()
		get_parent().interact()

#endregion

# ..............................................................................

#region FUNCTIONS

func interaction_area(player_base: PlayerBase, status: bool) -> void:
	if player_base.is_main_player:
		set_process_input(status)

#endregion

# ..............................................................................
