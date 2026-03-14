extends CanvasLayer

# ABILITIES UI (GLOBAL UI)

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# INPUT: accept events
	if event.is_action(&"esc"):
		Inputs.accept_event()

	# INPUT: esc -> exit ui
	if event.is_action_pressed(&"esc"):
		exit_ui()

#endregion

# ..............................................................................

#region FUNCTIONS

func exit_ui() -> void:
	Global.global_ui(Global.Ui.ABILITIES, Global.Ui.HOLO_DECK)

#endregion

# ..............................................................................
