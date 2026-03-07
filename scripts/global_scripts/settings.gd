extends Node

# SETTINGS (AUTOLOAD)

# Directory
# Windows: %APPDATA%\Godot\app_userdata\HoloSeries
# MacOS: ~/Library/Application Support/Godot/app_userdata/HoloSeries
# Linux: ~/.local/share/godot/app_userdata/HoloSeries

# ..............................................................................

#region CONSTANTS

const SETTINGS_PATH: String = "user://settings.cfg"
const DEFAULT_SETTINGS: Dictionary[String, Dictionary] = {
	"window": {
		"mode": DisplayServer.WINDOW_MODE_WINDOWED,
		"size": Vector2i(1280, 720),
		"position": Vector2i(640, 360),
	},
	"audio": {
		"master": 0.7,
		"music": 0.7,
	},
	"save": {
		"last_save": -1,
	},
	"input": {
		"sprint_toggle": false,
	},
}

const LOAD_ERROR_MESSAGE: String = "Failed to load settings: %s"
const SAVE_ERROR_MESSAGE: String = "Failed to save settings: %s"

#endregion

# ..............................................................................

#region VARIABLES

var settings: ConfigFile = ConfigFile.new()

#endregion

# ..............................................................................

#region STARTUP CONFIG

func _init() -> void:
	# load settings
	var config_state: int = settings.load(SETTINGS_PATH)

	# handle errors
	if config_state != OK:
		push_error(LOAD_ERROR_MESSAGE % error_string(config_state))
		set_default_settings()


func _ready() -> void:
	# set window mode, size, and position
	DisplayServer.window_set_mode(settings.get_value(
			"window", "mode", DEFAULT_SETTINGS["window"]["mode"]))
	DisplayServer.window_set_size(settings.get_value(
			"window", "size", DEFAULT_SETTINGS["window"]["size"]))
	DisplayServer.window_set_position(settings.get_value(
			"window", "position", DEFAULT_SETTINGS["window"]["position"]))

	# set audio volumes
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Master"),linear_to_db(
			settings.get_value("audio", "master", DEFAULT_SETTINGS["audio"]["master"])))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"BGM"), linear_to_db(
			settings.get_value("audio", "music", DEFAULT_SETTINGS["audio"]["music"])))

	# set input settings
	Inputs.sprint_toggle = settings.get_value(
			"input", "sprint_toggle", DEFAULT_SETTINGS["input"]["sprint_toggle"])

#endregion

# ..............................................................................

#region DEFAULT SETTINGS

func set_default_settings() -> void:
	for section in DEFAULT_SETTINGS:
		for key in DEFAULT_SETTINGS[section]:
			settings.set_value(section, key, DEFAULT_SETTINGS[section][key])

	save_settings()

#endregion

# ..............................................................................

#region LAST SAVE

func get_last_save() -> int:
	return settings.get_value("save", "last_save", DEFAULT_SETTINGS["save"]["last_save"])

#endregion

# ..............................................................................

#region SAVE SETTINGS

func save_settings() -> void:
	# save settings
	var config_state: int = settings.save(SETTINGS_PATH)

	# handle errors
	if config_state != OK:
		push_error(SAVE_ERROR_MESSAGE % error_string(config_state))

#endregion

# ..............................................................................

#region DISPLAY UPDATES

# toggle between fullscreen and windowed mode
func toggle_fullscreen(to_enabled: bool) -> void:
	DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN if to_enabled
			else DisplayServer.WINDOW_MODE_WINDOWED)
	settings.set_value("window", "mode", DisplayServer.window_get_mode())
	center_window_if_windowed()


# update window size
func set_window_size(window_size: Vector2i) -> void:
	DisplayServer.window_set_size(window_size)
	settings.set_value("window", "size", DisplayServer.window_get_size())
	center_window_if_windowed()


func center_window_if_windowed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		@warning_ignore("integer_division")
		DisplayServer.window_set_position(
				(DisplayServer.screen_get_size() - DisplayServer.window_get_size()) / 2)
		settings.set_value("window", "position", DisplayServer.window_get_position())

#endregion

# ..............................................................................

#region AUDIO UPDATES

func set_master_volume(db_value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Master"), db_value)
	settings.set_value("audio", "master", db_to_linear(db_value))


func set_music_volume(db_value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"BGM"), db_value)
	settings.set_value("audio", "music", db_to_linear(db_value))

#endregion

# ..............................................................................

#region EXIT

# save settings on exit
func _exit_tree() -> void:
	# save window mode, size, and position
	settings.set_value("window", "mode", DisplayServer.window_get_mode())
	settings.set_value("window", "size", DisplayServer.window_get_size())
	settings.set_value("window", "position", DisplayServer.window_get_position())

	save_settings()

#endregion

# ..............................................................................
