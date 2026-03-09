extends CanvasLayer

# MAIN MENU UI (UI)

# ..............................................................................

#region CONSTANTS

enum Menus {
	MAIN_OPTIONS,
	SAVES,
}

#endregion

# ..............................................................................

#region VARIABLES

@onready var menu_nodes: Dictionary[Menus, MarginContainer] = {
	Menus.MAIN_OPTIONS: %MainOptionsMenuMargin,
	Menus.SAVES: %SavesMenuMargin,
}

#endregion

# ..............................................................................

#region READY

func _ready() -> void:
	toggle_menus(Menus.MAIN_OPTIONS)

#endregion

# ..............................................................................

#region INPUTS

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"esc"):
		Inputs.accept_event()
		if not menu_nodes[Menus.MAIN_OPTIONS].is_visible():
			toggle_menus(Menus.MAIN_OPTIONS)
		elif Global.get_node_or_null(^"SettingsUi"):
			Global.global_ui(Global.Ui.SETTINGS, Global.Ui.NONE)
		else:
			Global.global_ui(Global.Ui.NONE, Global.Ui.SETTINGS)

#endregion

# ..............................................................................

#region FUNCTIONS

func toggle_menus(next_menu: Menus) -> void:
	for menu_node in menu_nodes.values():
		menu_node.hide()

	menu_nodes[next_menu].show()

#endregion

# ..............................................................................

#region MAIN OPTIONS MENU SIGNALS

func _on_play_button_pressed() -> void:
	await Players.camera.toggle_black_screen(true)
	Saves.load_last_save()


func _on_saves_button_pressed() -> void:
	toggle_menus(Menus.SAVES)


func _on_settings_button_pressed() -> void:
	Global.global_ui(Global.Ui.NONE, Global.Ui.SETTINGS)

#endregion

# ..............................................................................

#region SAVES MENU SIGNALS

func _on_back_button_pressed() -> void:
	toggle_menus(Menus.MAIN_OPTIONS)


func _on_new_game_button_pressed() -> void:
	Saves.new_save(0)

#endregion

# ..............................................................................
