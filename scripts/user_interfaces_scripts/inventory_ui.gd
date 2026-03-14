extends CanvasLayer

# INVENTORY UI (GLOBAL UI)

# ..............................................................................

#region INITIAL

func _ready() -> void:
	pass
	# for item_index in miscellaneous_buttons

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

#region ADD BUTTONS

func update_inventory(_inventory_index) -> void:
	pass


func exit_ui() -> void:
	Global.global_ui(Global.Ui.INVENTORY, Global.Ui.HOLO_DECK)


func _on_inventory_type_button_pressed(_extra_arg_0) -> void:
	pass

#endregion

# ..............................................................................
