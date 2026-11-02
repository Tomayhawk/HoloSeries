extends CanvasLayer

# HOLO DECK UI (GLOBAL UI)

# ..............................................................................

#region INITIAL

func _ready() -> void:
	Combat.ui.hide()
	Global.get_tree().paused = true

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# INPUT: esc -> resume game
	if event.is_action(&"esc"):
		Inputs.accept_event()
		if event.is_pressed():
			_on_resume_pressed()

#endregion

# ..............................................................................

#region SIGNALS

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
	Global.global_ui(Global.Ui.HOLO_DECK, Global.Ui.NONE)
	Global.get_tree().paused = false
	Combat.ui.show()


func _on_exit_game_pressed() -> void:
	pass # Replace with function body.

#endregion

# ..............................................................................
