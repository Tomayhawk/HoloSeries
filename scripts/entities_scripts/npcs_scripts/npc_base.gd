extends StaticBody2D

# TODO: input process should reflect main player changes

# ..............................................................................

#region VARIABLES

@onready var npc_node: AnimatedSprite2D = get_parent()

#endregion

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

	# GUARD: in combat || world_inputs_disabled -> ignore input
	# INPUT: interact -> start dialogue
	if (
			event.is_action_pressed(&"interact")
			and Inputs.world_inputs_enabled
			and Combat.not_in_combat()
	):
		npc_node.initiate_dialogue()

#endregion

# ..............................................................................

#region FUNCTIONS

# triggered on npc entering/exiting player interaction area
func interaction_area(player_base: PlayerBase, status: bool) -> void:
	if player_base.is_main_player:
		set_process_input(status)

#endregion

# ..............................................................................
