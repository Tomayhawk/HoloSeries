extends CanvasLayer

@onready var main_menu_scene: Node2D = Global.get_tree().current_scene

# ..............................................................................

#region INPUTS

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"esc"):
		Inputs.accept_event()
		if $SavesMenuMargin.is_visible():
			$SavesMenuMargin.hide()
			$OptionsMenuMargin.show()
		elif Global.get_node_or_null(^"SettingsUi"):
			Global.global_ui(Global.Ui.SETTINGS, Global.Ui.NONE)
		else:
			Global.global_ui(Global.Ui.NONE, Global.Ui.SETTINGS)

#endregion

# ..............................................................................

#region OPTIONS MENU

func _on_play_button_pressed() -> void:
	Saves.load_last_save()
	queue_free()


func _on_saves_button_pressed() -> void:
	$SavesMenuMargin.show()
	$OptionsMenuMargin.hide()


func _on_settings_button_pressed() -> void:
	Global.global_ui(Global.Ui.NONE, Global.Ui.SETTINGS)

#endregion

# ..............................................................................

#region SAVES MENU

func _on_back_button_pressed() -> void:
	$OptionsMenuMargin.show()
	$SavesMenuMargin.hide()

#endregion

# ..............................................................................
