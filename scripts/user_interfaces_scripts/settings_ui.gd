extends CanvasLayer

func _ready() -> void:
	# set size options
	const RESOLUTION_OPTIONS: Array[Vector2i] = [
			Vector2i(640, 480), Vector2i(800, 600), Vector2i(1024, 768), Vector2i(1280, 720),
			Vector2i(1280, 800), Vector2i(1280, 960), Vector2i(1280, 1024), Vector2i(1366, 768),
			Vector2i(1440, 900), Vector2i(1600, 900), Vector2i(1600, 1200), Vector2i(1680, 1050),
			Vector2i(1920, 1080), Vector2i(1920, 1200), Vector2i(2560, 1080), Vector2i(2560, 1440),
			Vector2i(3200, 1800), Vector2i(3440, 1440), Vector2i(3840, 1600), Vector2i(3840, 2160),
			Vector2i(5120, 2160), Vector2i(5120, 2880), Vector2i(7680, 4320)
	]

	var max_x: int = DisplayServer.screen_get_size().x
	var max_y: int = DisplayServer.screen_get_size().y

	for size in RESOLUTION_OPTIONS:
		if size.x <= max_x and size.y <= max_y:
			%ResolutionOptionButton.add_item(str(size.x) + " x " + str(size.y))

	# update full screen status
	%FullScreenCheckButton.set_pressed(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)

	# update selected size option
	var current_x: int = DisplayServer.window_get_size().x
	var current_y: int = DisplayServer.window_get_size().y

	for index in %ResolutionOptionButton.get_item_count():
		var size: PackedStringArray = %ResolutionOptionButton.get_item_text(index).split(" x ")

		if int(size[0]) == current_x and int(size[1]) == current_y:
			%ResolutionOptionButton.selected = index
			break

		if int(size[0]) > current_x and int(size[1]) > current_y:
			%ResolutionOptionButton.selected = -1
			break

	# update volume sliders
	%MasterVolumeHSlider.set_value(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Master"))))
	%MusicVolumeHSlider.set_value(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music"))))


func _input(event: InputEvent) -> void:
	# ignore unrelated inputs
	if not event.is_action(&"esc"):
		return

	Inputs.accept_event()

	if Input.is_action_just_pressed(&"esc"):
		exit_ui()

# ..............................................................................

# SIGNALS

func exit_ui() -> void:
	# TODO: temporary check method
	if get_tree().current_scene.name == "MainMenuScene":
		Global.global_ui(Global.Ui.SETTINGS, Global.Ui.NONE)
	else:
		Global.global_ui(Global.Ui.SETTINGS, Global.Ui.HOLO_DECK)

# SETTINGS

func _on_full_screen_check_button_toggled(to_enabled: bool) -> void:
	Settings.toggle_fullscreen(to_enabled)


func _on_resolution_option_button_item_selected(index: int) -> void:
	var resolution_dimensions: PackedStringArray = %ResolutionOptionButton.get_item_text(index).split(" x ")
	Settings.set_window_size(Vector2i(resolution_dimensions[0].to_int(), resolution_dimensions[1].to_int()))


func _on_master_volume_h_slider_value_changed(value: float) -> void:
	Settings.set_master_volume(linear_to_db(value))


func _on_music_volume_h_slider_value_changed(value: float) -> void:
	Settings.set_music_volume(linear_to_db(value))
