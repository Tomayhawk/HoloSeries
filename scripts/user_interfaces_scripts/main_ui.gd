extends CanvasLayer

@onready var main_scene: Node2D = Global.get_tree().current_scene

# ..............................................................................

#region OPTIONS MENU

func _on_play_button_pressed() -> void:
	Saves.load_save(Settings.get_last_save())
	queue_free()


func _on_saves_button_pressed() -> void:
	$SavesMenuMargin.show()
	$OptionsMenuMargin.hide()


func _on_settings_button_pressed() -> void:
	Global.add_global_child("SettingsUi", "res://user_interfaces/settings_ui.tscn")

#endregion

# ..............................................................................

#region SAVES MENU

func _on_back_button_pressed() -> void:
	$OptionsMenuMargin.show()
	$SavesMenuMargin.hide()

#endregion

# ..............................................................................
