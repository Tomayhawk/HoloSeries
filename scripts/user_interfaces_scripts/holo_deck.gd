extends CanvasLayer

# HOLO DECK (UI)

# ..............................................................................

#region READY

func _ready() -> void:
	# TODO: sometimes doesn't update input modes when hovering characters. need fix.
	Global.get_tree().set_pause(true)
	Inputs.world_inputs_enabled = false
	Inputs.action_inputs_enabled = false
	Inputs.zoom_inputs_enabled = false
	Combat.ui.hide()

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# ignore unrelated inputs
	if not event.is_action(&"esc"):
		return

	Inputs.accept_event()

	if Input.is_action_just_pressed(&"esc"):
		_on_resume_pressed()

#endregion

# ..............................................................................

#region BUTTON SIGNALS

func _on_characters_pressed() -> void:
	Global.global_ui(Global.Ui.HOLO_DECK, Global.Ui.CHARACTERS)


func _on_holo_nexus_pressed() -> void:
	Global.global_ui(Global.Ui.HOLO_DECK, Global.Ui.HOLO_NEXUS)


func _on_abilities_pressed() -> void:
	Global.global_ui(Global.Ui.HOLO_DECK, Global.Ui.ABILITIES)


func _on_inventory_pressed() -> void:
	Global.global_ui(Global.Ui.HOLO_DECK, Global.Ui.INVENTORY)


func _on_settings_pressed() -> void:
	Global.global_ui(Global.Ui.HOLO_DECK, Global.Ui.SETTINGS)


func _on_resume_pressed() -> void:
	Global.get_tree().set_pause(false)
	Inputs.world_inputs_enabled = true
	Inputs.action_inputs_enabled = true
	Inputs.zoom_inputs_enabled = true
	Combat.ui.show()
	Global.global_ui(Global.Ui.HOLO_DECK, Global.Ui.NONE)


func _on_exit_game_pressed() -> void:
	pass # Replace with function body.

#endregion

# ..............................................................................
