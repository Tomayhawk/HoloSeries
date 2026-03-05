extends CanvasLayer

# ..............................................................................

#region READY

func _ready() -> void:
	pass
	# for item_index in miscellaneous_buttons

#endregion

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

#region ADD BUTTONS

func update_inventory(_inventory_index) -> void:
	pass


func exit_ui() -> void:
	Global.add_global_child("HoloDeck", "res://user_interfaces/holo_deck.tscn")
	queue_free()


func _on_inventory_type_button_pressed(_extra_arg_0) -> void:
	pass

#endregion

# ..............................................................................
