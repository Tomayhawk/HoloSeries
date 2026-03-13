extends StaticBody2D

# TODO: input process should reflect main player changes

func _ready() -> void:
	set_process_input(false)

func _input(event: InputEvent) -> void:
	if (
			event.is_action_pressed(&"interact") # interaction button pressed
			and Inputs.world_inputs_enabled # world inputs are enabled
			 # event is an interaction event
			and get_parent().can_interact() # parent accepts interaction
	):
		Inputs.accept_event()
		get_parent().interact()

func interaction_area(player_base: PlayerBase, status: bool) -> void:
	if player_base.is_main_player:
		set_process_input(status)
