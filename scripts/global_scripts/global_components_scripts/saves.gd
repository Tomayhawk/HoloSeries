extends RefCounted

# SAVES

# Directory
# Windows: %APPDATA%\Godot\app_userdata\HoloSeries\saves
# MacOS: ~/Library/Application Support/Godot/app_userdata/HoloSeries/saves
# Linux: ~/.local/share/godot/app_userdata/HoloSeries/saves

# ..............................................................................

#region CONSTANTS

enum SavePoints {
	WORLD_SCENE_1_SPAWN,
}

enum SPKeys {
	SCENE,
	POSITION,
}

const SAVE_POINTS: Dictionary[SavePoints, Dictionary] = {
	SavePoints.WORLD_SCENE_1_SPAWN: {
		SPKeys.SCENE: Global.Scenes.WORLD_SCENE_1,
		SPKeys.POSITION: Vector2(0.0, 0.0),
	},
}

const SAVES_PATH: String = "user://saves/"
const SAVE_FILE_PATH: String = SAVES_PATH + "%s.dat"

# NEW SAVE

const SAVE_STRUCTURE: Dictionary[String, Variant] = {
	# save information
	"save_name": "",
	"save_point": SavePoints.WORLD_SCENE_1_SPAWN,
	"last_saved": 0.0,

	# inventories
	"consumables_inventory": [],
	"materials_inventory": [],
	"weapons_inventory": [],
	"armors_inventory": [],
	"accessories_inventory": [],
	"manager_inventory": [],
	"nexus_inventory": [],
	"keys_inventory": [],

	# nexus
	"nexus_types": [],
	"nexus_qualities": [],

	# characters
	"characters": [],

	# main player and party character indices
	"main_player": -1,
	"party": [-1, -1, -1, -1],
}

const CHARACTER_STRUCTURE: Dictionary[String, Variant] = {
	# stats
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
const MANAGER_INVENTORY_SIZE: int = 104
const NEXUS_INVENTORY_SIZE: int = 102
const KEYS_INVENTORY_SIZE: int = 103

# nexus
const NEXUS_GENERATOR_PATH: String = "res://scripts/holo_nexus_scripts/nexus_generator.gd"

# characters
const CHARACTERS_COUNT: int = 5

# LOAD SAVE

# errors
const SAVE_ERROR_MESSAGE: String = "[saves.gd] Invalid save file access: %s"

#endregion

# ..............................................................................

#region NEW SAVE

static func new_save(character_index: int) -> void:
	# create saves directory if it doesn't exist
	DirAccess.make_dir_absolute("user://saves")

	# create save
	var data: Dictionary[String, Variant] = SAVE_STRUCTURE.duplicate(true)

	# create save name
	var save_name: String = get_default_save_name()

	# GUARD: too many saves -> tell user to delete saves first
	if save_name == "":
		return # TODO: implement pop up

	# save information
	data["save_name"] = save_name
	data["last_saved"] = Time.get_unix_time_from_system()

	# inventories
	data["consumables_inventory"].resize(CONSUMABLES_INVENTORY_SIZE)
	data["materials_inventory"].resize(MATERIALS_INVENTORY_SIZE)
	data["manager_inventory"].resize(MANAGER_INVENTORY_SIZE)
	data["nexus_inventory"].resize(NEXUS_INVENTORY_SIZE)
	data["keys_inventory"].resize(KEYS_INVENTORY_SIZE)
	data["consumables_inventory"].fill(0)
	data["materials_inventory"].fill(0)
	data["manager_inventory"].fill(0)
	data["nexus_inventory"].fill(0)
	data["keys_inventory"].fill(0)

	# note: weapons, armors, and accessories inventories don't have set sizes

	# nexus
	var nexus_randomized: Array[Array] = load(NEXUS_GENERATOR_PATH).stats_nodes_randomizer()
	data["nexus_types"] = nexus_randomized[0]
	data["nexus_qualities"] = nexus_randomized[1]

	# characters
	data["characters"].resize(CHARACTERS_COUNT)
	data["characters"][character_index] = CHARACTER_STRUCTURE.duplicate(true)
	var player_stats: Resource = load(Players.CHARACTER_PATHS[character_index])
	data["characters"][character_index]["last_node"] = player_stats.CHARACTER_DEFAULT_UNLOCKED[1]
	data["characters"][character_index]["unlocked_nodes"] = player_stats.CHARACTER_DEFAULT_UNLOCKED

	# main player and party character indices
	data["main_player"] = character_index
	data["party"][0] = character_index

	# store save data to file
	var file_name: String = save_name_to_file_name(save_name)
	var file_path: String = SAVE_FILE_PATH % file_name
	save_data_to_file(file_path, data)

	# load save
	load_save(file_name)


static func get_default_save_name() -> String:
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

			# GUARD: data is not a dictionary -> continue to next file
			# GUARD: data doesn't have the "save_name" key -> continue to next file
			if not data is Dictionary or not data.has("save_name"):
				continue

			used_names.append(data["save_name"])

		file_name = dir.get_next()

	dir.list_dir_end()

	# get an available save name between "Save 0" and "Save 99"
	var save_name: String = ""

	for i in 100:
		var candidate_name: String = "Save %d" % i
		if not used_names.has(candidate_name):
			save_name = candidate_name
			break

	return save_name


static func save_name_to_file_name(save_name: String) -> String:
	var file_name: String = ""

	for c in save_name.strip_edges().to_lower().replace(" ", "_"):
		if c.is_valid_identifier() or c.is_valid_int() or c == "-":
			file_name += c

	return file_name

#endregion

# ..............................................................................

#region LOAD SAVE

static func load_last_save() -> void:
	var last_file_name: String = Settings.get_last_save()

	# GUARD: no previous save -> start new save
	if last_file_name != "":
		load_save(last_file_name)
	else:
		new_save(0) # TODO: should instead go to a "choose character" UI


static func load_save(file_name: String) -> void:
	# read save file
	var data: Dictionary = read_save_file(file_name)

	# GUARD: file doesn't exist -> notify user
	# GUARD: file data isn't a dictionary -> notify user
	if data.is_empty():
		push_error(SAVE_ERROR_MESSAGE % file_name)
		return

	Settings.set_last_save(file_name)

	# load inventories, nexus variables, players and scene
	load_inventories(data)
	load_nexus_variables(data)
	load_players(data)
	load_scene(data)


static func read_save_file(file_name: String) -> Dictionary:
	var file_path: String = SAVE_FILE_PATH % file_name

	# GUARD: file doesn't exist -> notify user
	if not FileAccess.file_exists(file_path):
		return {}

	# load save file as a dictionary
	var data: Variant = bytes_to_var(FileAccess.get_file_as_bytes(file_path))

	# GUARD: file data isn't a dictionary -> notify user
	if not data is Dictionary:
		push_error(SAVE_ERROR_MESSAGE % file_path)
		return {}

	return data


static func load_inventories(data: Dictionary) -> void:
	# set core inventories
	Inventory.consumables_inventory.assign(data["consumables_inventory"])
	Inventory.materials_inventory.assign(data["materials_inventory"])
	Inventory.weapons_inventory.assign(data["weapons_inventory"])
	Inventory.armors_inventory.assign(data["armors_inventory"])
	Inventory.accessories_inventory.assign(data["accessories_inventory"])
	Inventory.manager_inventory.assign(data["manager_inventory"])
	Inventory.nexus_inventory.assign(data["nexus_inventory"])
	Inventory.keys_inventory.assign(data["keys_inventory"])

	# update combat inventory ui
	Combat.ui.update_inventory_ui()


static func load_nexus_variables(data: Dictionary) -> void:
	Global.nexus_types.assign(data["nexus_types"])
	Global.nexus_qualities.assign(data["nexus_qualities"])


static func load_players(data: Dictionary) -> void:
	var character_index: int = 0

	for character_data in data["characters"]:
		# GUARD: character not unlocked -> continue to next character
		# GUARD: character data is not a dictionary -> continue to next character
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


static func load_scene(data: Dictionary) -> void:
	var save_point: Dictionary = SAVE_POINTS[data["save_point"]]
	Global.change_scene(Global.Scenes.MAIN_MENU, save_point[SPKeys.SCENE], save_point[SPKeys.POSITION])

#endregion

# ..............................................................................

#region SAVE

static func save(save_point: SavePoints) -> void:
	var current_file_name: String = Settings.get_last_save()
	var data: Dictionary[String, Variant] = read_save_file(current_file_name) # TODO: continue editing from here
	# TODO: also make use of CHARACTER_INDEX constants

	if data.is_empty():
		push_error(SAVE_ERROR_MESSAGE % current_file_name)
		return

	# save information
	data["save_point"] = save_point
	data["last_saved"] = Time.get_unix_time_from_system()

	# inventories
	data["consumables_inventory"] = Inventory.consumables_inventory.duplicate()
	data["materials_inventory"] = Inventory.materials_inventory.duplicate()
	data["weapons_inventory"] = Inventory.weapons_inventory.duplicate()
	data["armors_inventory"] = Inventory.armors_inventory.duplicate()
	data["accessories_inventory"] = Inventory.accessories_inventory.duplicate()
	data["manager_inventory"] = Inventory.manager_inventory.duplicate()
	data["nexus_inventory"] = Inventory.nexus_inventory.duplicate()
	data["keys_inventory"] = Inventory.keys_inventory.duplicate()

	# nexus
	data["nexus_types"] = Global.nexus_types.duplicate()
	data["nexus_qualities"] = Global.nexus_qualities.duplicate()

	# characters
	var character_index: int = 0
	for character_data in data["characters"]:
		if character_data is Dictionary:
			save_character(character_index, character_data)
		character_index += 1

	# store to file
	var file_path: String = SAVE_FILE_PATH % current_file_name
	save_data_to_file(file_path, data)
	dat_to_json(file_path) # TODO: temporary code


static func save_character(character_index: int, character_data: Dictionary) -> void:
	var stats: PlayerStats = get_character_stats(character_index)

	if not stats:
		push_error("[saves.gd] Could not retrieve stats for character index: %d" % character_index)
		return

	# experience
	character_data["experience"] = stats.experience

	# equipments
	character_data["weapon"] = Inventory.weapons_inventory.find(stats.weapon)
	character_data["headgear"] = Inventory.armors_inventory.find(stats.headgear)
	character_data["chestpiece"] = Inventory.armors_inventory.find(stats.chestpiece)
	character_data["leggings"] = Inventory.armors_inventory.find(stats.leggings)
	character_data["accessory_1"] = Inventory.accessories_inventory.find(stats.accessory_1)
	character_data["accessory_2"] = Inventory.accessories_inventory.find(stats.accessory_2)
	character_data["accessory_3"] = Inventory.accessories_inventory.find(stats.accessory_3)

	# nexus
	character_data["last_node"] = stats.last_node
	character_data["unlocked_nodes"] = stats.unlocked_nodes.duplicate()
	character_data["converted_nodes"] = stats.converted_nodes.duplicate()


static func get_character_stats(character_index: int) -> PlayerStats:
	# check party first
	for player_base in Players.party_bases:
		if is_instance_valid(player_base):
			return player_base.stats

	# check standby
	for stats in Players.standby_characters:
		if stats.get_script() == load(Players.CHARACTER_PATHS[character_index]):
			return stats

	return null


static func save_data_to_file(file_path: String, save_data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_buffer(var_to_bytes(save_data))
	file.close()

#endregion

# ..............................................................................

#region DEBUG

# TODO: temporary functions

static func migrate_json_to_dat() -> void:
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


static func json_to_dat(json_path: String) -> void:
	var file: FileAccess = FileAccess.open(json_path, FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()

	if not data is Dictionary:
		push_error(SAVE_ERROR_MESSAGE % json_path)
		return
	for character in data["characters"]:
		# GUARD: character not unlocked -> continue to next character
		if not character:
			continue

		var converted: Array[Vector2i] = []
		for value in character["converted_nodes"]:
			converted.append(Vector2i(int(value[0]), int(value[1])))
		character["converted_nodes"] = converted
	var temp_array: Array[int] = []
	temp_array.assign(data["party"])
	data["party"] = temp_array.duplicate()

	var dat_path: String = json_path.replace(".json", ".dat")
	save_data_to_file(dat_path, data)

	print("[LOG] [saves.gd] Migrated %s -> %s" % [json_path.get_file(), dat_path.get_file()])


static func dat_to_json(dat_path: String) -> void:
	var file: FileAccess = FileAccess.open(dat_path, FileAccess.READ)
	var data: Variant = bytes_to_var(file.get_buffer(file.get_length()))
	file.close()

	if not data is Dictionary:
		push_error(SAVE_ERROR_MESSAGE % dat_path)
		return
	for character in data["characters"]:
		# GUARD: character not unlocked -> continue to next character
		if not character:
			continue

		var flat_nodes: Array = []
		for vec in character["converted_nodes"]:
			flat_nodes.append([vec.x, vec.y])
		character["converted_nodes"] = flat_nodes

	var timestamp: String = Time.get_datetime_string_from_unix_time(data["last_saved"]).replace("T", "_").replace(":", "-")
	var json_path: String = dat_path.replace(".dat", "_%s.json" % timestamp)
	file = FileAccess.open(json_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

	print("[LOG] [saves.gd] Exported %s -> %s" % [dat_path.get_file(), json_path.get_file()])

#endregion

# ..............................................................................
