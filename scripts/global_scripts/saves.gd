extends Resource

# TODO: should use .dat

# Directory
# Windows: C:\Users\Username\AppData\Roaming\Godot\app_userdata\HoloSeries\saves
# Linux: /home/username/.local/share/godot/app_userdata/HoloSeries/saves

# ..............................................................................

#region CONSTANTS

# load save
const SAVE_FILE_PATH: String = "user://saves/save_%d.json"
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

const CONSUMABLES_INVENTORY_SIZE: int = 100
const MATERIALS_INVENTORY_SIZE: int = 101
const NEXUS_INVENTORY_SIZE: int = 102
const KEY_INVENTORY_SIZE: int = 103

#endregion

# ..............................................................................

#region NEXUS CONSTANTS

# NEXUS AREA BY ARRAY INDICES:
# 0  -> WHITE MAGIC
# 1  -> WHITE MAGIC 2
# 2  -> BLACK MAGIC
# 3  -> BLACK MAGIC 2
# 4  -> SUMMON
# 5  -> BUFF
# 6  -> DEBUFF
# 7  -> SPECIAL
# 8  -> SPECIAL 2
# 9  -> PHYSICAL
# 10 -> PHYSICAL 2
# 11 -> TANK

# note: this is offset by 1 for the array "nexus_types", which sets 0 to "EMPTY"
# STATS TYPE BY ARRAY VALUE:
# 0  -> HP   (Health)
# 1  -> MP   (Mana)
# 2  -> DEF  (Defense)
# 3  -> WRD  (Ward)
# 4  -> STR  (Strength)
# 5  -> INT  (Intelligence)
# 6  -> SPD  (Speed)
# 7  -> AGI  (Agility)

# [ROW: AREA_INDEX]
# nexus node indices in each nexus area
const INITIAL_AREA_NODES: Array[Array] = [
	[132, 133, 134, 146, 147, 149, 163, 164, 165, 166, 179, 182, 196, 198, 199, 211, 212, 213, 214, 215, 228, 229, 231, 232, 243, 244, 245, 246, 247, 260, 261, 262, 264, 277, 278, 279, 280, 292, 294, 296, 309, 310, 311, 324, 325, 327, 328, 340],
	[258, 274, 291, 306, 307, 322, 323, 338, 339, 354, 356, 371, 386, 387, 388, 403, 419],
	[456, 504, 520, 521, 536, 537, 538, 553, 554, 555, 567, 568, 570, 584, 585, 586, 587, 599, 601, 602, 603, 615, 616, 619, 631, 632, 633, 634, 648, 649, 650, 658, 664, 666, 667, 674, 675, 680, 682, 690, 691, 693, 696, 697, 698, 706, 707, 708, 709, 710, 712, 713, 714, 721, 722, 723, 724, 725, 726, 728, 729, 737, 738, 740, 741, 742, 743, 744, 745, 746, 752, 753, 756, 758, 759, 760, 761],
	[484, 499, 530, 562, 564, 565, 579, 580, 594, 595, 596, 597, 598, 611, 612, 627, 628, 644, 645, 646, 660, 661, 677, 678],
	[326, 341, 342, 357, 373, 389, 390, 404, 406, 421, 423, 437, 438, 439, 453, 455, 469, 470, 471, 485, 486, 487, 500, 501, 502, 503, 517, 534, 535, 551, 566],
	[2, 3, 4, 7, 16, 17, 19, 20, 21, 22, 23, 24, 32, 33, 34, 36, 37, 38, 41, 48, 49, 50, 51, 53, 54, 55, 56, 64, 66, 67, 70, 71, 72, 73, 80, 81, 82, 83, 86, 87, 88, 89, 96, 97, 98, 99, 105, 106, 118, 119, 121, 129, 135, 136, 137, 138, 145, 151, 152, 153, 168, 169, 184, 185, 201, 233, 249, 265],
	[144, 160, 161, 176, 193, 208, 224, 240, 257, 272, 288, 304, 320, 336, 352, 384, 385, 400, 401, 417, 432, 433, 449, 464, 480, 496, 512, 528, 529, 544, 545, 560, 561, 577, 593, 608, 609, 610, 624, 625, 640, 641, 642, 657, 672, 704, 705],
	[10, 11, 12, 26, 42, 43, 44, 58, 59, 60, 75, 90, 92, 108, 123, 124, 139, 154, 155, 156, 171, 173, 187, 188, 189, 190, 191, 203, 205, 207, 218, 219, 220, 223, 235, 236, 237, 238, 239, 250, 252, 253, 254, 266, 267, 268, 269, 270, 282, 283, 284, 297, 298, 300, 314, 315, 329, 330, 331, 345, 346],
	[13, 15, 29, 30, 46, 61, 78, 93, 95, 110, 111, 126, 127, 142, 143, 159],
	[364, 376, 377, 378, 379, 380, 393, 394, 395, 396, 397, 408, 409, 410, 411, 412, 425, 426, 427, 429, 441, 442, 443, 444, 445, 459, 460, 461, 474, 475, 476, 477, 491, 493, 494, 507, 508, 509, 523, 524, 525, 526, 540, 541, 542, 557, 558, 559, 572, 573, 574, 575, 591, 604, 605, 606, 607, 621, 623, 636, 652, 684, 699],
	[638, 653, 654, 655, 668, 669, 670, 671, 685, 686, 687, 700, 701, 703, 716, 718, 719, 731, 732, 733, 734, 748, 749, 750, 764, 765, 766],
	[271, 286, 287, 316, 317, 318, 319, 333, 334, 335, 348, 349, 350, 351, 366, 367, 398, 399, 414, 415, 430, 431, 447, 463, 479, 495, 510, 511]
]

# [ROW: AREA_INDEX][COL: STATS_TYPE]
# nexus stats populations in each nexus area
const BASE_AREA_STATS_COUNTS: Array[Array] = [
	[6, 11, 2, 5, 2, 6, 2, 2],
	[3, 4, 1, 2, 0, 2, 0, 0],
	[11, 18, 3, 4, 3, 10, 3, 3],
	[3, 6, 1, 2, 1, 3, 1, 1],
	[4, 4, 1, 1, 1, 4, 1, 1],
	[11, 8, 3, 3, 5, 4, 3, 3],
	[6, 8, 2, 2, 2, 4, 2, 2],
	[11, 7, 3, 2, 5, 3, 3, 3],
	[3, 2, 1, 0, 2, 1, 1, 1],
	[13, 4, 3, 2, 9, 1, 3, 3],
	[5, 1, 2, 1, 4, 0, 2, 2],
	[8, 2, 3, 1, 2, 1, 0, 0]
]

# [ROW: AREA_INDEX][COL: STATS_TYPE]
# nexus stats population flactuation ranges in each nexus area
const STATS_COUNT_FLACTUATION_RATE: Array[Array] = [
	[2, 3, 1, 1, 1, 2, 1, 1],
	[1, 1, 0, 1, 0, 1, 0, 0],
	[3, 5, 1, 1, 1, 3, 1, 1],
	[1, 2, 0, 1, 0, 1, 0, 0],
	[1, 1, 0, 0, 0, 1, 0, 0],
	[3, 2, 1, 1, 2, 1, 1, 1],
	[2, 2, 1, 1, 1, 1, 1, 1],
	[3, 2, 1, 1, 2, 1, 1, 1],
	[1, 1, 0, 0, 0, 0, 0, 0],
	[3, 1, 1, 1, 3, 0, 1, 1],
	[1, 0, 1, 0, 1, 0, 1, 1],
	[2, 1, 1, 1, 1, 0, 0, 0]
]

const NON_EMPTY_STATS_INDICES: Array[int] = [1, 2, 3, 4, 5, 6, 7, 8]
const NON_EMPTY_STATS_COUNT: int = 8

const area_stats_qualities := [
	[0, 0, 0, 0, 0, 0, 0, 0],
	[1, 2, 0, 2, 0, 2, 1, 1],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[1, 2, 0, 2, 0, 2, 1, 1],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 1, 1],
	[0, 0, 0, 0, 0, 0, 1, 1],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[1, 1, 1, 1, 1, 1, 2, 2],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[2, 1, 2, 0, 2, 0, 1, 1],
	[1, 0, 1, 1, 0, 0, 0, 0]
]

const stats_qualities := [
	[[200, 200, 300], [200, 200, 300, 300, 300, 400], [300, 300, 400]],
	[[10, 10, 20], [10, 10, 20, 20, 40], [20, 20, 40]],
	[[5, 10], [5, 10, 10, 15], [10, 15]],
	[[5, 10], [5, 10, 10, 15], [10, 15]],
	[[5, 5, 5, 10], [5, 10], [10]],
	[[5, 5, 5, 10], [5, 10], [10]],
	[[1, 1, 2, 2, 2, 3], [1, 2, 3, 3, 4], [3, 4]],
	[[1, 1, 2, 2, 2, 3], [1, 2, 3, 3, 4], [3, 4]],
]

const NEXUS_SET_TYPES: Array[int] = [9, 10, 0, 0, 0, 10, -1, 0, 10, 9, 0, 0, 0, 0, 9, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 13, 0, 9, -1, 0, 0, 9, 0, 0, 0, 9, 0, 0, 0, 10, -1, 0, 0, 0, 0, 11, 0, 9, 0, 0, 0, 0, 12, 0, 0, 0, 0, 10, 0, 0, 0, 0, -1, -1, 0, -1, 0, 0, -1, 14, 0, 0, 0, 0, -1, 0, 9, -1, 0, 13, 0, 0, 0, 0, 10, 12, 0, 0, 0, 0, 0, -1, 0, 0, 9, 0, 0, 0, 0, 0, 10, 10, 9, -1, 10, 0, 0, 9, 0, 9, 0, 0, 11, 9, -1, -1, 10, -1, 0, 0, -1, 0, -1, 0, 0, 14, 0, 0, -1, 0, 10, 10, 0, 0, 0, 0, 0, 0, 0, 0, 11, -1, 0, 0, 0, 0, 0, 0, -1, 0, -1, 0, 0, 0, 0, 0, 0, 9, -1, 0, 0, 0, 13, 0, 0, 0, 0, 10, 0, 0, 9, 0, -1, 0, -1, 9, 0, -1, 13, 0, 9, 10, 0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 11, 0, 10, -1, 0, -1, 0, 0, 13, 0, 13, 0, 9, 0, 9, 0, 0, -1, -1, 0, 0, 0, 0, 0, 10, -1, 0, 0, 0, -1, -1, 0, 0, 11, 13, 10, 0, 0, 12, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 14, 10, 0, 0, 0, 0, 0, -1, 0, 0, -1, 0, 0, 0, 11, 11, 0, 0, 14, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 0, -1, 10, 0, 0, 0, 0, -1, 0, 0, 0, 9, 0, 0, 0, 9, -1, 0, 0, 10, 0, 10, 0, 0, 0, 9, 0, 12, -1, 14, 0, 10, 0, 0, -1, 0, 0, 0, -1, 9, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, -1, 10, 0, 0, 9, 0, 0, 0, 0, 0, 11, 0, 10, 0, 0, -1, 15, 15, -1, -1, -1, 0, -1, 0, 0, 11, -1, 13, 0, -1, 0, 0, 9, 0, 0, 0, 0, 0, 0, -1, 9, 0, 0, 0, 0, 0, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, -1, 0, 0, -1, 0, 11, 0, 10, 0, -1, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 10, -1, -1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 13, 0, 9, 0, 15, 10, 11, 0, 9, 0, 0, 13, 9, 0, 0, 0, 9, 0, 0, -1, 10, 14, 0, 0, 0, 0, 11, 14, 0, 0, 0, 0, -1, 0, 0, 11, 9, -1, 0, 0, 0, 0, -1, 11, -1, 0, -1, 0, 0, 0, 0, 13, 13, 0, 0, 0, 0, 0, 0, 11, -1, 0, 0, 0, 0, 0, 0, -1, -1, 15, -1, 0, -1, 0, 0, 0, 11, 0, 0, 0, 0, -1, 0, 0, 0, 11, 15, 0, 0, 0, 0, 0, 0, 15, 0, 0, 0, 9, 0, 0, 11, 11, 11, -1, -1, 0, -1, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 0, 0, -1, 0, -1, 0, 0, 0, 0, 9, 0, -1, 0, 0, 15, 11, -1, 0, 0, 0, 0, 12, -1, 9, 0, -1, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, 0, 0, -1, 11, 0, -1, 0, -1, 0, 0, 0, -1, 0, 0, 11, 11, 0, 0, 0, 0, 9, 0, 9, 0, -1, 0, 0, 0, 11, 0, 0, 0, 14, 0, 0, 0, -1, 0, 0, 0, 0, 11, 0, 0, -1, 0, 0, -1, -1, 0, -1, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 11, 0, 0, 11, 0, 11, 0, 14, 0, 0, 0, 0, 11, -1, 0, 0, -1, 0, 13, 12, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 14, 0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 11, 0, 0, 11, 0, 0, 0, 0, 15, 11, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 15, 0, 0, 11, 11, 0, 11, 0, 0, 0, 0, 11, 9, 0, 0, 0, 9]

# has_illegal_adjacents() constants

const NEXUS_NODE_COUNT: int = 768
const NEXUS_ROW_SIZE: int = 32
const NEXUS_HALF_ROW: int = 16

const NEXUS_ADJACENTS_OFFSETS: Array[Array] = [
	[-32, -17, -16, 15, 16, 32], [-32, -16, -15, 16, 17, 32]
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
	save_data["consumables_inventory"].fill(0)
	save_data["materials_inventory"].fill(0)
	save_data["nexus_inventory"].fill(0)
	save_data["key_inventory"].fill(0)

	# initialize nexus
	stat_nodes_randomizer()
	save_data["nexus_types"] = Global.nexus_types
	save_data["nexus_qualities"] = Global.nexus_qualities

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
	var file_path: String = SAVE_FILE_PATH % save_index

	# check file exists
	if not FileAccess.file_exists(file_path):
		# TODO: should instead pop up a text box and return to menu
		push_error(FILE_ERROR_MESSAGE % file_path)
		return {}

	# load save file as a dictionary
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())

	file.close()

	# check dictionary exists
	if not data is Dictionary:
		# TODO: should instead pop up a text box and return to menu
		push_error(DATA_ERROR_MESSAGE % file_path)
		return {}

	return data


func load_inventories(data: Dictionary) -> void:
	# set core inventories
	set_int_array(data["consumables_inventory"], Inventory.consumables_inventory)
	set_int_array(data["materials_inventory"], Inventory.materials_inventory)
	set_int_array(data["weapons_inventory"], Inventory.weapons_inventory)
	set_int_array(data["armors_inventory"], Inventory.armors_inventory)
	set_int_array(data["accessories_inventory"], Inventory.accessories_inventory)
	set_int_array(data["nexus_inventory"], Inventory.nexus_inventory)
	set_int_array(data["key_inventory"], Inventory.key_inventory)

	# update combat inventory ui
	Combat.ui.update_inventory_ui()


func load_nexus_variables(data: Dictionary) -> void:
	set_int_array(data["nexus_types"], Global.nexus_types)
	set_int_array(data["nexus_qualities"], Global.nexus_qualities)


func load_characters(data: Dictionary) -> Array[PlayerStats]:
	# update characters
	var character_stats: Array[PlayerStats] = []
	character_stats.resize(CHARACTER_SCRIPTS.size())
	character_stats.fill(null)

	for character_data in data["characters"]:
		var character_index: int = character_data["character_index"]
		var stats: PlayerStats = load(CHARACTER_SCRIPTS[character_index]).new()

		character_stats[character_index] = stats

		# experience
		stats.update_experience(character_data["experience"])

		# equipments
		stats.weapon = null if character_data["weapon"] == -1 else Inventory.weapons[character_data["weapon"]]
		stats.headgear = null if character_data["headgear"] == -1 else Inventory.armors[character_data["headgear"]]
		stats.chestpiece = null if character_data["chestpiece"] == -1 else Inventory.armors[character_data["chestpiece"]]
		stats.leggings = null if character_data["leggings"] == -1 else Inventory.armors[character_data["leggings"]]
		stats.accessory_1 = null if character_data["accessory_1"] == -1 else Inventory.accessories[character_data["accessory_1"]]
		stats.accessory_2 = null if character_data["accessory_2"] == -1 else Inventory.accessories[character_data["accessory_2"]]
		stats.accessory_3 = null if character_data["accessory_3"] == -1 else Inventory.accessories[character_data["accessory_3"]]

		# nexus
		stats.last_node = character_data["last_node"]
		set_int_array(character_data["unlocked_nodes"], stats.unlocked_nodes)
		set_converted_nodes(character_data["converted_nodes"], stats.converted_nodes) # TODO: will not work because of Vector2i

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
			if character_index == main_player_index: player_base.is_main_player = true
			player_base.set_variables(character_stats[character_index], party_index)
			character_stats[character_index] = null
			Players.add_child(player_base)

	# set standby characters
	for character in character_stats:
		if not character: continue
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

#region LOAD SAVE UTLITIES

func set_int_array(save_array: Array, target_inventory: Array[int]) -> void:
	# * target_inventory.clear()

	for value in save_array:
		target_inventory.append(int(value))


func set_converted_nodes(save_array: Array, converted_nodes: Array[Vector2i]) -> void:
	# * converted_nodes.clear()

	for value in save_array:
		converted_nodes.append(Vector2i(int(value[0]), int(value[1])))

#endregion

# ..............................................................................

#region SAVE

func save(_save_index: int) -> void:
	pass

#endregion

# ..............................................................................

#region NEW NEXUS

# randomizes empty nexus nodes with randomized stat types and stat qualities
func stat_nodes_randomizer() -> void: # TODO: need to change
	var area_nodes: Array[Array] = INITIAL_AREA_NODES
	var stats_type_quantities: Array[Array] = BASE_AREA_STATS_COUNTS
	var area_types: Array[int] = []
	var area_size: int = 0
	var area_texture_positions_size: int = 0
	var index: int = 0

	var node_qualities: Array[int] = []
	node_qualities.resize(768)
	node_qualities.fill(0)

	var nexus_types: Array[int] = NEXUS_SET_TYPES

	# for each area
	for area_index in area_nodes.size():
		area_size = area_nodes[area_index].size()

		# randomize the number of each stat type
		for stat_index in NON_EMPTY_STATS_COUNT:
			stats_type_quantities[area_index][stat_index] += round(STATS_COUNT_FLACTUATION_RATE[area_index][stat_index] * (randf_range(-0.25, 0.25) + randf_range(-0.25, 0.25) + randf_range(-0.25, 0.25) + randf_range(-0.25, 0.25)))

		# create an array of Vector2 positions for area stat nodes
		area_types.clear()

		for stat_type in stats_type_quantities[area_index].size():
			for j in stats_type_quantities[area_index][stat_type]:
				area_types.append(NON_EMPTY_STATS_INDICES[stat_type])

		for remaining_nodes in (area_size - area_types.size() + 1):
			area_types.append(0)

		# find satifying stat type for each node
		area_nodes[area_index].shuffle()
		area_types.shuffle()

		area_texture_positions_size = area_types.size()

		for node_index in area_nodes[area_index]:
			index = 0
			while index < area_texture_positions_size:
				nexus_types[node_index] = area_types[area_texture_positions_size - 1 - index]
				if has_illegal_adjacents(nexus_types, node_index):
					index += 1
				else:
					area_types.pop_at(area_texture_positions_size - 1 - index)
					area_texture_positions_size -= 1
					break

			if index >= area_texture_positions_size and area_texture_positions_size > 0:
				nexus_types[node_index] = area_types.pop_at(randi() % (area_texture_positions_size))
				area_texture_positions_size -= 1

	for area_index in area_nodes.size():
		for node_index in area_nodes[area_index]:
			for stat_index in NON_EMPTY_STATS_COUNT:
				if nexus_types[node_index] == NON_EMPTY_STATS_INDICES[stat_index]:
					node_qualities[node_index] = stats_qualities[stat_index][area_stats_qualities[area_index][stat_index]][randi() % stats_qualities[stat_index][area_stats_qualities[area_index][stat_index]].size()]

	# TODO: TEMPORARY CODE
	Global.nexus_types = nexus_types
	Global.nexus_qualities = node_qualities

#endregion

# ..............................................................................

#region NEW NEXUS UTILITIES

# TODO: mediocre illegal classification settings
# TODO: should handle cases with nexus board edges
func has_illegal_adjacents(nexus_types: Array[int], node_index: int) -> bool:
	var node_type: int = nexus_types[node_index]

	# set adjacent indices
	for offset in NEXUS_ADJACENTS_OFFSETS[0 if node_index % 32 < 16 else 1]:
		var adjacent_index: int = node_index + offset
		# valid index and shares node type with origin -> illegal
		if adjacent_index >= 0 and adjacent_index < NEXUS_NODE_COUNT:
			if node_type == nexus_types[adjacent_index]:
				return true

	# no adjacent node shares the same type as origin -> legal
	return false

#endregion

# ..............................................................................
