extends CanvasLayer

# SETTINGS UI (GLOBAL UI)

const OPTION_BUTTON_PRELOAD: Resource = \
		preload("res://user_interfaces/settings_ui_components/dropdown_option_button.tscn")

# ..............................................................................

#region INITIAL

func _ready() -> void:
	initialize_resolution_options()

	# update full screen status
	%FullScreenCheckButton.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	Settings.full_screen_toggled.connect(full_screen_toggled)

	# update volume sliders
	%MasterVolumeHSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Master")))
	%MusicVolumeHSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")))

	Inputs.zoom_inputs_enabled = false

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

func initialize_resolution_options() -> void:
	# set size options
	const RESOLUTION_OPTIONS: Array[Vector2i] = [
			Vector2i(640, 480), Vector2i(800, 600), Vector2i(1024, 768), Vector2i(1280, 720),
			Vector2i(1280, 800), Vector2i(1280, 960), Vector2i(1280, 1024), Vector2i(1366, 768),
			Vector2i(1440, 900), Vector2i(1600, 900), Vector2i(1600, 1200), Vector2i(1680, 1050),
			Vector2i(1920, 1080), Vector2i(1920, 1200), Vector2i(2560, 1080), Vector2i(2560, 1440),
			Vector2i(3200, 1800), Vector2i(3440, 1440), Vector2i(3840, 1600), Vector2i(3840, 2160),
			Vector2i(5120, 2160), Vector2i(5120, 2880), Vector2i(7680, 4320),
	]

	var max_x: int = DisplayServer.screen_get_size().x
	var max_y: int = DisplayServer.screen_get_size().y

	# add option buttons
	for size in RESOLUTION_OPTIONS:
		if size.x <= max_x and size.y <= max_y:
			var option_button: Button = OPTION_BUTTON_PRELOAD.instantiate()
			option_button.get_node(^"Label").text = \
					str(size.x) + " x " + str(size.y)

			%ResolutionsVBoxContainer.add_child(option_button)
			option_button.pressed.connect(_on_resolution_option_selected.bind(size))

	# update current size
	%ResolutionButton/Label.text = \
			str(DisplayServer.window_get_size().x) + " x " \
			+ str(DisplayServer.window_get_size().y)


func exit_ui() -> void:
	Inputs.zoom_inputs_enabled = true

	if get_tree().current_scene.name == &"MainMenuScene":
		Global.global_ui(Global.Ui.SETTINGS, Global.Ui.NONE)
	else:
		Global.global_ui(Global.Ui.SETTINGS, Global.Ui.HOLO_DECK)

#endregion

# ..............................................................................

#region SIGNALS

func full_screen_toggled(to_enabled: bool) -> void:
	%FullScreenCheckButton.button_pressed = to_enabled


func _on_full_screen_check_button_toggled(to_enabled: bool) -> void:
	Settings.toggle_full_screen(to_enabled)


func _on_resolution_button_pressed() -> void:
	var expand_options: bool = not %ResolutionsMarginContainer.visible
	%ResolutionsMarginContainer.visible = expand_options

	%ResolutionButton.toggle_mode = expand_options


func _on_resolution_option_selected(size: Vector2i) -> void:
	%ResolutionButton/Label.text = str(size.x) + " x " + str(size.y)
	%ResolutionButton.toggle_mode = false
	%ResolutionsMarginContainer.hide()

	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		Settings.toggle_full_screen(false)

	Settings.set_window_size(size)


func _on_master_volume_h_slider_value_changed(value: float) -> void:
	Settings.set_master_volume(linear_to_db(value))


func _on_music_volume_h_slider_value_changed(value: float) -> void:
	Settings.set_music_volume(linear_to_db(value))


func _on_resolutions_margin_container_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"action"):
		%ResolutionButton.toggle_mode = false
		%ResolutionsMarginContainer.hide()

#endregion

# ..............................................................................
