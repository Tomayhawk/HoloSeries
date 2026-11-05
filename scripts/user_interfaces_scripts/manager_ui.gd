extends CanvasLayer

# MANAGER UI (GLOBAL UI)

# ..............................................................................

#region CONSTANTS

# const DATA: Resource = preload("res://scripts/holo_manager_scripts/manager_data.gd")

#endregion

# ..............................................................................

#region VARIABLES

var dragging_block: Control = null

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# INPUT: esc -> exit ui
	if event.is_action(&"esc"):
		Inputs.accept_event()
		if event.is_pressed():
			exit_ui()

#endregion

# ..............................................................................

#region FUNCTIONS

func exit_ui() -> void:
	Global.global_ui(Global.Ui.MANAGER, Global.Ui.HOLO_DECK)

#endregion

# ..............................................................................
