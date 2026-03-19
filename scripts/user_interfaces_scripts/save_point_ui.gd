extends CanvasLayer

# SAVE POINT UI (GLOBAL UI)

# ..............................................................................

#region READY

func _ready() -> void:
	Global.pause_movement()

#endregion

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
	Global.global_ui(Global.Ui.SAVE_POINT, Global.Ui.NONE)
	Global.resume_movement()

#endregion

# ..............................................................................
