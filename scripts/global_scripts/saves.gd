extends RefCounted

# Directory
# Windows: C:\Users\Tomay\AppData\Roaming\Godot\app_userdata\HoloSeries\saves
# Linux: /home/tomay/.local/share/godot/app_userdata/HoloSeries/saves

# ..............................................................................

#region CONSTANTS

# new save
const CONSUMABLES_INVENTORY_SIZE: int = 100
const MATERIALS_INVENTORY_SIZE: int = 101
const NEXUS_INVENTORY_SIZE: int = 102
const KEY_INVENTORY_SIZE: int = 103

const NEXUS_GENERATOR_PATH: String = "res://scripts/global_scripts/nexus_generator.gd"

# load save
const SAVE_FILE_PATH: String = "user://saves/save_%d.dat"
const FILE_ERROR_MESSAGE: String = "[saves.gd] Save file not found: %s"
const DATA_ERROR_MESSAGE: String = "[saves.gd] Failed to parse save file: %s"
const PLAYER_BASE_PATH: String = "res://entities/player_base.tscn"
const CHARACTER_SCRIPTS: Array[String] = [
	"res://scripts/entities_scripts/players_scripts/character_scripts/sora.gd",
	"res://scripts/entities_scripts/players_scripts/character_scripts/azki.gd",
	"res://scripts/entities_scripts/players_scripts/character_scripts/roboco.gd",
	"res://scripts/entities_scripts/players_scripts/character_scripts/akirose.gd",
	"res://scripts/entities_scripts/players_scripts/character_scripts/luna.gd",
]

#endregion

# ..............................................................................

#region NEW SAVE

func new_save(character_index: int) -> void:
	var player_stats: PlayerStats = load(CHARACTER_SCRIPTS[character_index]).new()

	# initialize save
	var save_data: Dictionary = {
		# scene
		"scene_path": "res://scenes/world_scene_1.tscn" as String,

		# inventories
		"consumables_inventory": [] as Array[int],
		"materials_inventory": [] as Array[int],
		"weapons_inventory": [] as Array[int],
		"armors_inventory": [] as Array[int],
		"accessories_inventory": [] as Array[int],
		"nexus_inventory": [] as Array[int],
		"key_inventory": [] as Array[int],

		# nexus
		"nexus_types": [] as Array[int],
		"nexus_qualities": [] as Array[int],

		# character stats
		"characters": [
			{
				# stats
				"character_index": character_index as int,
				"experience": 0 as int,

				# equipments
				"weapon": -1 as int,
				"headgear": -1 as int,
				"chestpiece": -1 as int,
				"leggings": -1 as int,
				"accessory_1": -1 as int,
				"accessory_2": -1 as int,
				"accessory_3": -1 as int,

				# nexus
				"last_node": player_stats.DEFAULT_UNLOCKED[1] as int,
				"unlocked_nodes": player_stats.DEFAULT_UNLOCKED as Array[int],
				"converted_nodes": [] as Array[Vector2i],
			}
		] as Array[Dictionary],

		# players
		"main_player": character_index as int,
		"main_player_position": [0.0, 0.0] as Array[float],
		"party": [character_index, -1, -1, -1] as Array[int],
	}

	# initialize inventories
	save_data["consumables_inventory"].resize(CONSUMABLES_INVENTORY_SIZE)
	save_data["materials_inventory"].resize(MATERIALS_INVENTORY_SIZE)
	save_data["nexus_inventory"].resize(NEXUS_INVENTORY_SIZE)
	save_data["key_inventory"].resize(KEY_INVENTORY_SIZE)

	# initialize nexus
	var nexus_randomized: Array[Array] = load(NEXUS_GENERATOR_PATH).new().stats_nodes_randomizer()
	save_data["nexus_types"] = nexus_randomized[0]
	save_data["nexus_qualities"] = nexus_randomized[1]

	# create saves directory if it doesn't exist
	var dir: DirAccess = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

	# find an empty save file
	var file_path: String = ""
	var save_index: int = 1
	for index in [1, 2, 3]:
		var test_path: String = "user://saves/save_%d.json" % index
		if not FileAccess.file_exists(test_path):
			file_path = test_path
			save_index = index
			break

	# store save data
	if file_path != "":
		var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(save_data))
		file.close()

	# load save
	load_save(save_index)

#endregion

# ..............................................................................

#region LOAD SAVE

func load_save(save_index: int = 1) -> void:
	# read save file
	var data: Dictionary = read_save_file(save_index)

	if data.is_empty():
		return

	# load inventories and nexus variables
	load_inventories(data)
	load_nexus_variables(data)

	# load players and standby characters
	var character_stats: Array[PlayerStats] = load_characters(data)
	load_players(data, character_stats)

	# load scene
	load_scene(data)


func read_save_file(save_index: int) -> Dictionary:
	# TODO: temporary code
	_migrate_json_saves()

	var file_path: String = SAVE_FILE_PATH % save_index

	# check file exists
	if not FileAccess.file_exists(file_path):
		# TODO: should instead pop up a text box and return to menu
		push_error(FILE_ERROR_MESSAGE % file_path)
		return {}

	# load save file as a dictionary
	var bytes := FileAccess.get_file_as_bytes(file_path)

	var data = bytes_to_var(bytes)

	# check dictionary exists
	if not data is Dictionary:
		# TODO: should instead pop up a text box and return to menu
		push_error(DATA_ERROR_MESSAGE % file_path)
		return {}

	return data


func load_inventories(data: Dictionary) -> void:
	# set core inventories
	Inventory.consumables_inventory.assign(data["consumables_inventory"])
	Inventory.materials_inventory.assign(data["materials_inventory"])
	Inventory.weapons_inventory.assign(data["weapons_inventory"])
	Inventory.armors_inventory.assign(data["armors_inventory"])
	Inventory.accessories_inventory.assign(data["accessories_inventory"])
	Inventory.nexus_inventory.assign(data["nexus_inventory"])
	Inventory.key_inventory.assign(data["key_inventory"])

	# update combat inventory ui
	Combat.ui.update_inventory_ui()


func load_nexus_variables(data: Dictionary) -> void:
	Global.nexus_types.assign(data["nexus_types"])
	Global.nexus_qualities.assign(data["nexus_qualities"])


func load_characters(data: Dictionary) -> Array[PlayerStats]:
	# update characters
	var character_stats: Array[PlayerStats] = []
	character_stats.resize(CHARACTER_SCRIPTS.size())

	for character_data in data["characters"]:
		var character_index: int = character_data["character_index"]
		var stats: PlayerStats = load(CHARACTER_SCRIPTS[character_index]).new()
		character_stats[character_index] = stats
		stats.load_character(character_data)

	return character_stats


func load_players(data: Dictionary, character_stats: Array[PlayerStats]) -> void:
	# set party players
	var main_player_index: int = data["main_player"]
	for party_index in data["party"].size():
		var character_index: int = data["party"][party_index]
		if character_index == -1:
			Combat.ui.name_labels[party_index].get_parent().modulate.a = 0.0
		else:
			var player_base: Node = load(PLAYER_BASE_PATH).instantiate()
			if character_index == main_player_index:
				player_base.is_main_player = true
			player_base.set_variables(character_stats[character_index], party_index)
			character_stats[character_index] = null
			Players.add_child(player_base)

	# set standby characters
	for character in character_stats:
		if not character:
			continue

		character.set_stats()
		Players.standby_characters.append(character)
		Combat.ui.add_standby_character(character)


func load_scene(data: Dictionary) -> void:
	var main_player_position: Vector2 = Vector2(data["main_player_position"][0], data["main_player_position"][1])
	# TODO: should be more dynamic
	Global.change_scene(
			data["scene_path"],
			main_player_position,
			[ - 10000000, -10000000, 10000000, 10000000],
			"res://music/asmarafulldemo.mp3")

#endregion

# ..............................................................................

#region SAVE

func save(_save_index: int) -> void:
	pass

#endregion

# ..............................................................................

# TODO: temporary functions

func _migrate_json_saves() -> void:
	var dir: DirAccess = DirAccess.open("user://saves")
	if not dir:
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".json"):
			_convert_json_to_dat("user://saves/" + file_name)
		file_name = dir.get_next()

	dir.list_dir_end()

func _convert_json_to_dat(json_path: String) -> void:
	var file := FileAccess.open(json_path, FileAccess.READ)
	if not file:
		push_error("[saves.gd] Could not open JSON save: %s" % json_path)
		return

	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if not data is Dictionary:
		push_error("[saves.gd] Failed to parse JSON save: %s" % json_path)
		return

	data = _migrate_data(data)

	var dat_path := json_path.replace(".json", ".dat")
	write_save(dat_path, data)
	print("[saves.gd] Migrated %s -> %s" % [json_path, dat_path])


func write_save(file_path: String, data: Dictionary) -> void:
	var bytes := var_to_bytes(data)
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("[saves.gd] Could not write save: %s" % file_path)
		return
	file.store_buffer(bytes)
	file.close()

func _migrate_data(data: Dictionary) -> Dictionary:
	# fix converted_nodes from [[x,y], ...] to Array[Vector2i]
	for character in data["characters"]:
		var converted: Array[Vector2i] = []
		for value in character["converted_nodes"]:
			converted.append(Vector2i(int(value[0]), int(value[1])))
		character["converted_nodes"] = converted

	return data
