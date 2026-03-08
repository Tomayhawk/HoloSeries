extends CanvasLayer

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# ignore unrelated inputs
	if not event.is_action(&"esc"):
		return

	Inputs.accept_event()

	if Input.is_action_just_pressed(&"esc"):
		exit_ui()

#endregion

# ..............................................................................

#region FUNCTIONS

func exit_ui() -> void:
	Global.global_ui(Global.Ui.ABILITIES, Global.Ui.HOLO_DECK)

#endregion

# ..............................................................................
