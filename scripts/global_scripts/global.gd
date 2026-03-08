extends Node

# TODO: refactor?

# GLOBAL (AUTOLOAD #1)

# ..............................................................................

#region SIGNALS

signal new_scene_ready

#endregion

# ..............................................................................

#region CONSTANTS

# GLOBAL UI

enum Ui {
	NONE,
	ABILITIES,
	CHARACTERS,
	HOLO_DECK,
	HOLO_NEXUS,
	INVENTORY,
	MAIN_MENU,
	SETTINGS,
	TEXT_BOX,
}

enum UiKeys {
	NAME,
	PATH,
}

# WORLD SCENES

enum Scenes {
	MAIN_MENU,
	WORLD_SCENE_1,
	WORLD_SCENE_2,
	DUNGEON_SCENE_1,
}

enum ScenesKeys {
	POSITION,
	CAMERA_LIMITS,
	MUSIC,
}

# BACKGROUND MUSIC

enum Music {
	OH_ASMARA,
	SHUNKAN_HEARTBEAT,
}

# GLOBAL UI

const GLOBAL_UI_PATH_BASE = "res://user_interfaces/%s.tscn"

const GLOBAL_UI: Dictionary[Ui, Dictionary] = {
	Ui.ABILITIES: {
		UiKeys.NAME: ^"AbilitiesUi",
		UiKeys.PATH: GLOBAL_UI_PATH_BASE % "abilities_ui",
	},
	Ui.CHARACTERS: {
		UiKeys.NAME: ^"CharactersUi",
		UiKeys.PATH: GLOBAL_UI_PATH_BASE % "characters_ui",
	},
	Ui.HOLO_DECK: {
		UiKeys.NAME: ^"HoloDeck",
		UiKeys.PATH: GLOBAL_UI_PATH_BASE % "holo_deck",
	},
	Ui.HOLO_NEXUS: {
		UiKeys.NAME: ^"HoloNexus",
		UiKeys.PATH: GLOBAL_UI_PATH_BASE % "holo_nexus",
	},
	Ui.INVENTORY: {
		UiKeys.NAME: ^"InventoryUi",
		UiKeys.PATH: GLOBAL_UI_PATH_BASE % "inventory_ui",
	},
	Ui.MAIN_MENU: {
		UiKeys.NAME: ^"MainMenuUi",
		UiKeys.PATH: GLOBAL_UI_PATH_BASE % "main_menu_ui",
	},
	Ui.SETTINGS: {
		UiKeys.NAME: ^"SettingsUi",
		UiKeys.PATH: GLOBAL_UI_PATH_BASE % "settings_ui",
	},
	Ui.TEXT_BOX: {
		UiKeys.NAME: ^"TextBox",
		UiKeys.PATH: GLOBAL_UI_PATH_BASE % "text_box",
	},
}

# WORLD SCENES

const SCENE_PATHS: Dictionary[Scenes, String] = {
	Scenes.WORLD_SCENE_1: "res://scenes/world_scene_1.tscn",
	Scenes.WORLD_SCENE_2: "res://scenes/world_scene_2.tscn",
	Scenes.DUNGEON_SCENE_1: "res://scenes/dungeon_scene_1.tscn",
}

const WORLD_SCENES: Dictionary[Scenes, Dictionary] = {
	Scenes.MAIN_MENU: {
		Scenes.WORLD_SCENE_1: {
			ScenesKeys.POSITION: Vector2(0.0, 0.0),
			ScenesKeys.CAMERA_LIMITS: [-10000000, -10000000, 10000000, 10000000],
			ScenesKeys.MUSIC: MUSIC_PATHS[Music.OH_ASMARA],
		},
	},
	Scenes.WORLD_SCENE_1: {
		Scenes.WORLD_SCENE_2: {
			ScenesKeys.POSITION: Vector2(0.0, 341.0),
			ScenesKeys.CAMERA_LIMITS: [-640, -352, 640, 352],
			ScenesKeys.MUSIC: MUSIC_PATHS[Music.OH_ASMARA],
		},
	},
	Scenes.WORLD_SCENE_2: {
		Scenes.WORLD_SCENE_1: {
			ScenesKeys.POSITION: Vector2(0.0, -247.0),
			ScenesKeys.CAMERA_LIMITS: [-208, -288, 224, 64],
			ScenesKeys.MUSIC: MUSIC_PATHS[Music.OH_ASMARA],
		},
		Scenes.DUNGEON_SCENE_1: {
			ScenesKeys.POSITION: Vector2(0.0, 53.0),
			ScenesKeys.CAMERA_LIMITS: [-10000000, -10000000, 10000000, 10000000],
			ScenesKeys.MUSIC: MUSIC_PATHS[Music.SHUNKAN_HEARTBEAT],
		},
	},
	Scenes.DUNGEON_SCENE_1: {
		Scenes.WORLD_SCENE_2: {
			ScenesKeys.POSITION: Vector2(31.0, -103.0),
			ScenesKeys.CAMERA_LIMITS: [-640, -352, 640, 352],
			ScenesKeys.MUSIC: MUSIC_PATHS[Music.OH_ASMARA],
		},
	},
}

# BACKGROUND MUSIC

const MUSIC_PATHS: Dictionary[Music, String] = {
	Music.OH_ASMARA: "res://music/asmarafulldemo.mp3",
	Music.SHUNKAN_HEARTBEAT: "res://music/shunkandemo3.mp3",
}

#endregion

# ..............................................................................

#region VARIABLES

# NEXUS VARIABLES

# -1: null
# 0: empty
# 1-8: HP, MP, DEF, WRD, STR, INT, SPD, AGI
# 9-11: special, white magic, black magic
# 12-15: diamond, clover, heart, spade
var nexus_types: Array[int] = []

# -1 for all non-stats nodes
var nexus_qualities: Array[int] = []

#endregion

# ..............................................................................

#region SCENE CHANGE

func change_scene(current_scene: Scenes, next_scene: Scenes) -> void:
	var next_scene_path: String = SCENE_PATHS[next_scene]
	var next_position: Vector2 = WORLD_SCENES[current_scene][next_scene][ScenesKeys.POSITION]
	var camera_limits: Array[int] = []
	var music_path: String = WORLD_SCENES[current_scene][next_scene][ScenesKeys.MUSIC]

	camera_limits.assign(WORLD_SCENES[current_scene][next_scene][ScenesKeys.CAMERA_LIMITS])

	# disable inputs
	Inputs.action_inputs_enabled = false
	Inputs.world_inputs_enabled = false
	Inputs.zoom_inputs_enabled = false

	# disable camera smoothing
	Players.camera.position_smoothing_enabled = false

	# start black screen
	await Players.camera.toggle_black_screen(true)

	# disable players
	Players.toggle_process(false)

	# reparent players and main camera to self
	Players.reparent.call_deferred(self)

	# change scene
	get_tree().change_scene_to_file.call_deferred(next_scene_path)

	# wait for scene to load
	await new_scene_ready

	# update music
	start_music(music_path)

	# reparent players to the new scene
	Players.reparent(get_tree().current_scene)

	# reposition players and update camera
	for player_base in Players.get_children():
		if player_base.is_main_player:
			player_base.position = next_position
			Players.camera.force_zoom(Players.camera.target_zoom)
			Players.camera.update_camera_limits(camera_limits)
		else:
			player_base.ally_teleport(next_position)

	# reset world objects and values
	Entities.end_entities_request()
	Combat.clear_combat_entities()
	Combat.leave_combat()

	# move Inputs to the bottom of the tree
	get_tree().root.move_child(Inputs, -1)

	# await 2 frames to ensure everything is loaded
	await get_tree().process_frame
	await get_tree().process_frame

	# enable players
	Players.toggle_process(true)

	# end black screen
	Players.camera.toggle_black_screen(false)

	# enable camera smoothing
	Players.camera.position_smoothing_enabled = true

	# enable inputs
	Inputs.action_inputs_enabled = true
	Inputs.world_inputs_enabled = true
	Inputs.zoom_inputs_enabled = true

#endregion

# ..............................................................................

#region GLOBAL UI

func global_ui(current_ui: Ui, next_ui: Ui) -> void:
	if not current_ui == Ui.NONE:
		get_node(GLOBAL_UI[current_ui][UiKeys.NAME]).queue_free()

	if not next_ui == Ui.NONE:
		add_child(load(GLOBAL_UI[next_ui][UiKeys.PATH]).instantiate())

#endregion

# ..............................................................................

#region Music

func start_music(music_path: String) -> void:
	# return if currently playing the same track
	if $MusicPlayer.stream.resource_path == music_path:
		return

	# free old music player if applicable
	if get_node_or_null(^"OldMusicPlayer"):
		$OldMusicPlayer.queue_free()
		await $OldMusicPlayer.tree_exited

	# no tweens if no volume (or low volume)
	if AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")) < -70.0:
		$MusicPlayer.stream = load(music_path)
		$MusicPlayer.play()
		return

	# turn down old music player
	$MusicPlayer.name = "OldMusicPlayer"
	var tween_1 = $OldMusicPlayer.create_tween()
	tween_1.tween_property($OldMusicPlayer, "volume_db", -80.0, 3.0) \
			.set_trans(Tween.TRANS_LINEAR) \
			.set_ease(Tween.EASE_OUT)

	# initialize new music player
	var new_music_player = AudioStreamPlayer.new()
	add_child(new_music_player)

	new_music_player.name = "MusicPlayer"
	$MusicPlayer.stream = load(music_path)
	$MusicPlayer.bus = "Music"
	$MusicPlayer.volume_db = -80.0

	$MusicPlayer.play()

	# turn up new music player
	$MusicPlayer.create_tween().tween_property($MusicPlayer, "volume_db",
			AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")), 4.0) \
			.set_trans(Tween.TRANS_EXPO) \
			.set_ease(Tween.EASE_OUT)

	# free old music player
	await tween_1.finished
	if get_node_or_null(^"OldMusicPlayer"):
		$OldMusicPlayer.queue_free()

#endregion

# ..............................................................................
