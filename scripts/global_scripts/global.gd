extends Node

# GLOBAL (AUTOLOAD #1)

# ..............................................................................

#region SIGNALS

signal new_scene_ready

#endregion

# ..............................................................................

#region UI ENUMS

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

#endregion

# ..............................................................................

#region SCENES ENUMS

enum Scenes {
	MAIN_MENU,
	WORLD_SCENE_1,
	WORLD_SCENE_2,
	DUNGEON_SCENE_1,
}

enum ScenesKeys {
	CAMERA_LIMITS,
	MUSIC,
}

#endregion

# ..............................................................................

#region MUSIC ENUMS

enum Music {
	OH_ASMARA,
	SHUNKAN_HEARTBEAT,
}

#endregion

# ..............................................................................

#region PATHS CONSTANTS

const GLOBAL_UI_PATH = "res://user_interfaces/%s.tscn"

const SCENE_PATHS: Dictionary[Scenes, String] = {
	Scenes.MAIN_MENU: "res://scenes/main_menu_scene.tscn",
	Scenes.WORLD_SCENE_1: "res://scenes/world_scene_1.tscn",
	Scenes.WORLD_SCENE_2: "res://scenes/world_scene_2.tscn",
	Scenes.DUNGEON_SCENE_1: "res://scenes/dungeon_scene_1.tscn",
}

const MUSIC_PATHS: Dictionary[Music, String] = {
	Music.OH_ASMARA: "res://music/asmarafulldemo.mp3",
	Music.SHUNKAN_HEARTBEAT: "res://music/shunkandemo3.mp3",
}

#endregion

# ..............................................................................

#region UI DICTIONARY

const GLOBAL_UI: Dictionary[Ui, Dictionary] = {
	Ui.ABILITIES: {
		UiKeys.NAME: ^"AbilitiesUi",
		UiKeys.PATH: GLOBAL_UI_PATH % "abilities_ui",
	},
	Ui.CHARACTERS: {
		UiKeys.NAME: ^"CharactersUi",
		UiKeys.PATH: GLOBAL_UI_PATH % "characters_ui",
	},
	Ui.HOLO_DECK: {
		UiKeys.NAME: ^"HoloDeckUi",
		UiKeys.PATH: GLOBAL_UI_PATH % "holo_deck_ui",
	},
	Ui.HOLO_NEXUS: {
		UiKeys.NAME: ^"HoloNexus",
		UiKeys.PATH: "res://holo_nexus/holo_nexus.tscn", # TODO: maybe put this somewhere else
	},
	Ui.INVENTORY: {
		UiKeys.NAME: ^"InventoryUi",
		UiKeys.PATH: GLOBAL_UI_PATH % "inventory_ui",
	},
	Ui.MAIN_MENU: {
		UiKeys.NAME: ^"MainMenuUi",
		UiKeys.PATH: GLOBAL_UI_PATH % "main_menu_ui",
	},
	Ui.SETTINGS: {
		UiKeys.NAME: ^"SettingsUi",
		UiKeys.PATH: GLOBAL_UI_PATH % "settings_ui",
	},
	Ui.TEXT_BOX: {
		UiKeys.NAME: ^"TextBoxUi",
		UiKeys.PATH: GLOBAL_UI_PATH % "text_box_ui",
	},
}

#endregion

# ..............................................................................

#region SCENES DICTIONARIES

const SCENES_DICT: Dictionary[Scenes, Dictionary] = {
	Scenes.WORLD_SCENE_1: {
		ScenesKeys.CAMERA_LIMITS: [-208, -288, 224, 64],
		ScenesKeys.MUSIC: Music.OH_ASMARA,
	},
	Scenes.WORLD_SCENE_2: {
		ScenesKeys.CAMERA_LIMITS: [-640, -352, 640, 352],
		ScenesKeys.MUSIC: Music.OH_ASMARA,
	},
	Scenes.DUNGEON_SCENE_1: {
		ScenesKeys.CAMERA_LIMITS: [-10000000, -10000000, 10000000, 10000000],
		ScenesKeys.MUSIC: Music.SHUNKAN_HEARTBEAT,
	},
}

const SCENE_CHANGES: Dictionary[Scenes, Dictionary] = {
	Scenes.WORLD_SCENE_1: {
		Scenes.WORLD_SCENE_2: Vector2(0.0, 341.0),
	},
	Scenes.WORLD_SCENE_2: {
		Scenes.WORLD_SCENE_1: Vector2(0.0, -247.0),
		Scenes.DUNGEON_SCENE_1: Vector2(0.0, 53.0),
	},
	Scenes.DUNGEON_SCENE_1: {
		Scenes.WORLD_SCENE_2: Vector2(31.0, -103.0),
	},
}

#endregion

# ..............................................................................

#region VARIABLES

# NEXUS

var nexus_types: Array[int] = []
var nexus_qualities: Array[int] = []

#endregion

# ..............................................................................

#region GLOBAL UI

func open_text_box(npc: AnimatedSprite2D, file_path: String) -> void:
	var text_box_node: CanvasLayer = load(GLOBAL_UI[Ui.TEXT_BOX][UiKeys.PATH]).instantiate()
	add_child(text_box_node)
	text_box_node.npc_dialogue(npc, file_path)


func global_ui(current_ui: Ui, next_ui: Ui) -> void:
	if not current_ui == Ui.NONE:
		get_node(GLOBAL_UI[current_ui][UiKeys.NAME]).queue_free()

	if not next_ui == Ui.NONE:
		add_child(load(GLOBAL_UI[next_ui][UiKeys.PATH]).instantiate())

#endregion

# ..............................................................................

#region SCENE CHANGE

func change_scene(current_scene: Scenes, next_scene: Scenes, set_position: Vector2 = Vector2.ZERO) -> void:
	var camera_limits: Array[int] = []
	camera_limits.assign(SCENES_DICT[next_scene][ScenesKeys.CAMERA_LIMITS])

	# disable world inputs and players
	Inputs.toggle_world_inputs(false)
	Players.toggle_process(false)

	# start black screen
	await Players.camera.toggle_black_screen(true)

	# reparent players to self
	Players.reparent.call_deferred(self)

	# change scene
	get_tree().change_scene_to_file.call_deferred(SCENE_PATHS[next_scene])

	# reposition party
	warp_party(set_position if current_scene == Scenes.MAIN_MENU
			else SCENE_CHANGES[current_scene][next_scene])

	# update camera
	Players.camera.force_zoom(Players.camera.target_zoom)
	Players.camera.update_camera_limits(camera_limits)

	# reset world objects and values
	Entities.end_entities_request()
	Entities.clear_scene_entities()
	Damage.clear_damage_displays()
	Combat.end_combat()

	# wait for scene to load
	await new_scene_ready

	# reparent players to the new scene
	Players.reparent(get_tree().current_scene)

	# move Inputs to the bottom of the tree
	get_tree().root.move_child(Inputs, -1)

	# update music
	start_music(SCENES_DICT[next_scene][ScenesKeys.MUSIC])

	# end black screen
	Players.camera.toggle_black_screen(false)

	# enable players and world inputs
	Players.toggle_process(true)
	Inputs.toggle_world_inputs(true)


func warp_party(next_position: Vector2) -> void:
	# reposition main player
	Players.main_player.position = next_position

	# reposition ally players
	for player_base in Players.party_bases:
		if is_instance_valid(player_base) and not player_base.is_main_player:
			player_base.ally_teleport(next_position)

#endregion

# ..............................................................................

#region MUSIC

func start_music(music: Music) -> void:
	var music_path: String = MUSIC_PATHS[music]

	var current_music_player: AudioStreamPlayer = $MusicPlayer

	# GUARD: same track -> continue playing
	if current_music_player.stream.resource_path == music_path:
		return

	var old_music_player: AudioStreamPlayer = get_node_or_null(^"OldMusicPlayer")

	# GUARD: old music player still exists -> free it
	if old_music_player:
		old_music_player.name = &"FreedMusicPlayer"
		old_music_player.queue_free()

	var music_volume: float = \
			AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music"))

	# GUARD: low volume -> set new track with no tweens
	if music_volume < -70.0:
		current_music_player.stream = load(music_path)
		current_music_player.play()
		return

	# turn down current music player
	current_music_player.name = &"OldMusicPlayer"

	# set tween, tween properties, and queue free current music player when finished
	var tween: Tween = current_music_player.create_tween()
	tween.tween_property(current_music_player, "volume_db", -80.0, 3.0
			).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func() -> void: current_music_player.queue_free())

	# initialize next music player
	var next_music_player := AudioStreamPlayer.new()

	add_child(next_music_player)

	next_music_player.name = &"MusicPlayer"
	next_music_player.bus = &"Music"
	next_music_player.volume_db = -80.0
	next_music_player.stream = load(music_path)
	next_music_player.play()

	# turn up new music player
	next_music_player.create_tween().tween_property(next_music_player, "volume_db",
			music_volume, 4.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

#endregion

# ..............................................................................
