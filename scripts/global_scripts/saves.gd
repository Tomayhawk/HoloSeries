extends Node

# SAVES (AUTOLOAD #10)

# TODO: add "last played" save information and sort saves in UI based on that

# Directory
# Windows: %APPDATA%\Godot\app_userdata\HoloSeries\saves
# MacOS: ~/Library/Application Support/Godot/app_userdata/HoloSeries/saves
# Linux: ~/.local/share/godot/app_userdata/HoloSeries/saves

# ..............................................................................

#region CONSTANTS

const SAVES_PATH: String = "user://saves/"
const SAVE_FILE_PATH: String = SAVES_PATH + "%s.dat"

# NEW SAVE

const SAVE_STRUCTURE: Dictionary = {
	# save information
	"save_name": "",
	"last_saved": 0.0,

	# scene
	"scene": Global.Scenes.WORLD_SCENE_1,

	# inventories
	"consumables_inventory": [],
	"materials_inventory": [],
	"weapons_inventory": [],
	"armors_inventory": [],
	"accessories_inventory": [],
	"nexus_inventory": [],
	"key_inventory": [],

	# nexus
	"nexus_types": [],
	"nexus_qualities": [],

	# characters
	"characters": [],

	# main player and party character indices
	"main_player": -1,
	"position": Vector2(0.0, 0.0),
	"party": [-1, -1, -1, -1],
}

const CHARACTER_STRUCTURE: Dictionary = {
	# stats
	"level": 0,
	"experience": 0,

	# equipments
	"weapon": -1,
	"headgear": -1,
	"chestpiece": -1,
	"leggings": -1,
	"accessory_1": -1,
	"accessory_2": -1,
	"accessory_3": -1,

	# nexus
	"last_node": -1,
	"unlocked_nodes": [],
	"converted_nodes": [],
}

# inventories
const CONSUMABLES_INVENTORY_SIZE: int = 100
const MATERIALS_INVENTORY_SIZE: int = 101
const NEXUS_INVENTORY_SIZE: int = 102
const KEY_INVENTORY_SIZE: int = 103

# nexus
const NEXUS_GENERATOR_PATH: String = "res://scripts/global_scripts/nexus_generator.gd"

# characters
const CHARACTERS_COUNT: int = 5

# LOAD SAVE

# errors
const FILE_ERROR_MESSAGE: String = "[saves.gd] Save file not found: %s"
const DATA_ERROR_MESSAGE: String = "[saves.gd] Failed to parse save file: %s"

#endregion

# ..............................................................................

#region INITIALIZE

# TODO: temporary function
func _init() -> void:
	migrate_json_to_dat()

#endregion

# ..............................................................................

#region NEW SAVE

func new_save(character_index: int) -> void:
	# create saves directory if it doesn't exist
	DirAccess.make_dir_absolute("user://saves")

	# create save
	var data: Dictionary = SAVE_STRUCTURE.duplicate(true)

	# create save name
	var save_name: String = get_default_save_name()

	# EDGE CASE: no default save names available. too many saves
	if save_name == "":
		return

	# save information
	data["save_name"] = save_name
	data["last_saved"] = Time.get_unix_time_from_system()

	# inventories
	data["consumables_inventory"].resize(CONSUMABLES_INVENTORY_SIZE)
	data["materials_inventory"].resize(MATERIALS_INVENTORY_SIZE)
	data["nexus_inventory"].resize(NEXUS_INVENTORY_SIZE)
	data["key_inventory"].resize(KEY_INVENTORY_SIZE)

	# note: weapons, armors, and accessories inventories don't have set sizes

	# nexus
	var nexus_randomized: Array[Array] = load(NEXUS_GENERATOR_PATH).new().stats_nodes_randomizer()
	data["nexus_types"] = nexus_randomized[0]
	data["nexus_qualities"] = nexus_randomized[1]

	# characters
	data["characters"].resize(CHARACTERS_COUNT)
	data["characters"][character_index] = CHARACTER_STRUCTURE.duplicate(true)
	var player_stats: PlayerStats = load(Players.CHARACTER_PATHS[character_index]).new()
	data["characters"][character_index]["last_node"] = player_stats.DEFAULT_UNLOCKED[1]
	data["characters"][character_index]["unlocked_nodes"] = player_stats.DEFAULT_UNLOCKED

	# main player and party character indices
	data["main_player"] = character_index
	data["party"][0] = character_index

	# store save data to file
	var file_name: String = save_name_to_file_name(save_name)
	var file_path: String = SAVE_FILE_PATH % file_name
	save_data_to_file(file_path, data)

	# load save
	load_save(file_name)


func get_default_save_name() -> String:
	var dir: DirAccess = DirAccess.open(SAVES_PATH)
	var used_names: Array = []

	dir.list_dir_begin()

	var file_name: String = dir.get_next()

	# get existing save names
	while file_name != "":
		if file_name.ends_with(".dat"):
			var file: FileAccess = FileAccess.open(SAVES_PATH + file_name, FileAccess.READ)
			var data: Variant = bytes_to_var(file.get_buffer(file.get_length()))
			file.close()

			# EDGE CASE: data is not a dictionary OR data doesn't have the key "save_name"
			if not data is Dictionary and not data.has("save_name"):
				continue

			used_names.append(data["save_name"])

		file_name = dir.get_next()

	dir.list_dir_end()

	# get an available save name between "Save 0" and "Save 99"
	var save_name: String = ""

	for i in 100:
		save_name = "Save %d" % i
		if not used_names.has(save_name):
			break

	return save_name


func save_name_to_file_name(save_name: String) -> String:
	var file_name: String = ""

	for c in save_name.strip_edges().to_lower().replace(" ", "_"):
		if c.is_valid_identifier() or c == "-":
			file_name += c

	return file_name

#endregion

# ..............................................................................

#region LOAD SAVE

func load_last_save() -> void:
	var last_file_name: String = Settings.get_last_save()

	if last_file_name != "":
		load_save(last_file_name)
	else:
		new_save(0) # TODO: should instead go to a "choose character" UI


func load_save(file_name: String) -> void:
	# read save file
	var data: Dictionary = read_save_file(file_name)

	# EDGE CASE: file doesn't exist OR file data isn't a dictionary
	if data.is_empty():
		return

	Settings.set_last_save(file_name)

	# load inventories, nexus variables, players and scene
	load_inventories(data)
	load_nexus_variables(data)
	load_players(data)
	load_scene(data)


func read_save_file(file_name: String) -> Dictionary:
	var file_path: String = SAVE_FILE_PATH % file_name

	# EDGE CASE: file doesn't exist
	if not FileAccess.file_exists(file_path):
		push_error(FILE_ERROR_MESSAGE % file_path)
		return {}

	# load save file as a dictionary
	var data: Variant = bytes_to_var(FileAccess.get_file_as_bytes(file_path))

	# EDGE CASE: file data isn't a dictionary
	if not data is Dictionary:
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


func load_players(data: Dictionary) -> void:
	var character_index: int = 0

	for character_data in data["characters"]:
		# EDGE CASE: character not unlocked OR character data is not a dictionary
		if not character_data or not character_data is Dictionary:
			character_index += 1
			continue

		# load character stats
		var stats: PlayerStats = Players.load_player_stats(character_index, character_data as Dictionary)

		# add character to party or standby accordingly
		var party_index: int = data["party"].find(character_index)
		var is_main_player: bool = character_index == data["main_player"]

		if party_index == -1:
			Players.add_standby_character(stats)
		else:
			Players.add_party_player(stats, party_index, is_main_player)

		character_index += 1


func load_scene(data: Dictionary) -> void:
	#var position: Vector2 = Vector2(data["position"][0], data["position"][1])
	# TODO: should be more dynamic
	Global.change_scene(Global.Scenes.MAIN_MENU, data["scene"])

#endregion

# ..............................................................................

#region SAVE

func save(_save_name: String) -> void:
	pass


func save_data_to_file(file_path: String, save_data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_buffer(var_to_bytes(save_data))
	file.close()

#endregion

# ..............................................................................

#region DEBUG

# TODO: temporary functions

func migrate_json_to_dat() -> void:
	var dir: DirAccess = DirAccess.open(SAVES_PATH)

	if not dir:
		return

	dir.list_dir_begin()

	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			json_to_dat(SAVES_PATH + file_name)
		file_name = dir.get_next()

	dir.list_dir_end()


func json_to_dat(json_path: String) -> void:
	var file: FileAccess = FileAccess.open(json_path, FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()

	if not data is Dictionary:
		push_error(DATA_ERROR_MESSAGE % json_path)
		return
	for character in data["characters"]:
		# EDGE CASE: character not unlocked
		if not character:
			continue

		var converted: Array[Vector2i] = []
		for value in character["converted_nodes"]:
			converted.append(Vector2i(int(value[0]), int(value[1])))
		character["converted_nodes"] = converted
	data["position"] = Vector2(float(data["position"][0]), float(data["position"][1]))
	var temp_array: Array[int] = []
	temp_array.assign(data["party"])
	data["party"] = temp_array.duplicate()

	var dat_path: String = json_path.replace(".json", ".dat")
	save_data_to_file(dat_path, data)

	print("[LOG] [saves.gd] Migrated %s -> %s" % [json_path.get_file(), dat_path.get_file()])


func dat_to_json(dat_path: String) -> void:
	var file: FileAccess = FileAccess.open(dat_path, FileAccess.READ)
	var data: Variant = bytes_to_var(file.get_buffer(file.get_length()))
	file.close()

	if not data is Dictionary:
		push_error(DATA_ERROR_MESSAGE % dat_path)
		return
	for character in data["characters"]:
		# EDGE CASE: character not unlocked
		if not character:
			continue

		var flat_nodes: Array = []
		for vec in character["converted_nodes"]:
			flat_nodes.append([vec.x, vec.y])
		character["converted_nodes"] = flat_nodes
	data["position"] = [data["position"].x, data["position"].y]

	var timestamp: String = Time.get_datetime_string_from_unix_time(data["last_saved"]).replace("T", "_").replace(":", "-")
	var json_path: String = dat_path.replace(".dat", "_%s.json" % timestamp)
	file = FileAccess.open(json_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

	print("[LOG] [saves.gd] Exported %s -> %s" % [dat_path.get_file(), json_path.get_file()])

#endregion

# ..............................................................................
