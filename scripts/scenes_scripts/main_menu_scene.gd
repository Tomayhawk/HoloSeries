extends CanvasLayer

# MAIN MENU (SCENE)

# ..............................................................................

#region CONSTANTS

enum Menus {
	MAIN_OPTIONS,
	SAVES,
}

const SAVES_PATH: String = \
		"res://scripts/global_scripts/global_components_scripts/saves.gd"

#endregion

# ..............................................................................

#region VARIABLES

@onready var menu_nodes: Dictionary[Menus, MarginContainer] = {
	Menus.MAIN_OPTIONS: %MainOptionsMenuMargin,
	Menus.SAVES: %SavesMenuMargin,
}

#endregion

# ..............................................................................

#region INITIAL

func _ready() -> void:
	toggle_menus(Menus.MAIN_OPTIONS)
	%PlayButton.text = "New Game" if Settings.get_last_save() == "" else "Continue"

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# INPUT: esc -> handle esc inputs
	if event.is_action(&"esc"):
		Inputs.accept_event()
		if event.is_pressed() and not event.is_echo():
			esc_input()

#endregion

# ..............................................................................

#region INPUT FUNCTIONS

func esc_input() -> void:
	# return to main options menu from sibling menus,
	# or switch between main options and settings menus
	if not menu_nodes[Menus.MAIN_OPTIONS].is_visible():
		toggle_menus(Menus.MAIN_OPTIONS)
	elif Global.has_node(^"SettingsUi"):
		Global.global_ui(Global.Ui.SETTINGS, Global.Ui.NONE)
	else:
		Global.global_ui(Global.Ui.NONE, Global.Ui.SETTINGS)

#endregion

# ..............................................................................

#region FUNCTIONS

# switch between main options menu and sibling menus
func toggle_menus(next_menu: Menus) -> void:
	for menu_node in menu_nodes.values():
		menu_node.hide()

	menu_nodes[next_menu].show()

#endregion

# ..............................................................................

#region MAIN OPTIONS MENU SIGNALS

func _on_play_button_pressed() -> void:
	await Players.camera.toggle_black_screen(true)
	load(SAVES_PATH).load_last_save()


func _on_saves_button_pressed() -> void:
	toggle_menus(Menus.SAVES)


func _on_achievements_button_pressed() -> void:
	pass


func _on_settings_button_pressed() -> void:
	Global.global_ui(Global.Ui.NONE, Global.Ui.SETTINGS)

#endregion

# ..............................................................................

#region SAVES MENU SIGNALS

func _on_back_button_pressed() -> void:
	toggle_menus(Menus.MAIN_OPTIONS)


func _on_new_game_button_pressed() -> void:
	load(SAVES_PATH).new_save(0)

#endregion

# ..............................................................................
