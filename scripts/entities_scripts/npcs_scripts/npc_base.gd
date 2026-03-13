extends StaticBody2D

# TODO: input process should reflect main player changes

# ..............................................................................

#region VARIABLES

@onready var npc_node: Node = get_parent()

#endregion

# ..............................................................................

#region READY

func _ready() -> void:
	set_process_input(false)

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# EDGE CASE: not interact pressed || text box is active || in combat || world_inputs_disabled -> ignore input
	if (
			event.is_action_pressed(&"interact")
			and TextBox.is_inactive()
			and Combat.not_in_combat()
			and Inputs.world_inputs_enabled
	):
		Inputs.accept_event()
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
