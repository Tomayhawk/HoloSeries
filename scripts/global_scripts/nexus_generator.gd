extends RefCounted

# NEXUS GENERATOR

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
# 0 -> HP   (Health)
# 1 -> MP   (Mana)
# 2 -> DEF  (Defense)
# 3 -> WRD  (Ward)
# 4 -> STR  (Strength)
# 5 -> INT  (Intelligence)
# 6 -> SPD  (Speed)
# 7 -> AGI  (Agility)

# ..............................................................................

#region NEXUS CONSTANTS

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

const NEXUS_AREA_COUNT: int = 12
const BASIC_STATS_TYPES_INDICES: Array[int] = [1, 2, 3, 4, 5, 6, 7, 8]
const BASIC_STATS_TYPES_COUNT: int = 8

const STATS_TYPES_QUALITIES := [
	[[200, 200, 300], [200, 200, 300, 300, 300, 400], [300, 300, 400]],
	[[10, 10, 20], [10, 10, 20, 20, 40], [20, 20, 40]],
	[[5, 10], [5, 10, 10, 15], [10, 15]],
	[[5, 10], [5, 10, 10, 15], [10, 15]],
	[[5, 5, 5, 10], [5, 10], [10]],
	[[5, 5, 5, 10], [5, 10], [10]],
	[[1, 1, 2, 2, 2, 3], [1, 2, 3, 3, 4], [3, 4]],
	[[1, 1, 2, 2, 2, 3], [1, 2, 3, 3, 4], [3, 4]],
]

const AREA_STATS_QUALITIES_INDICES := [
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

const NEXUS_SET_TYPES: Array[int] = [9, 10, 0, 0, 0, 10, -1, 0, 10, 9, 0, 0, 0, 0, 9, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 13, 0, 9, -1, 0, 0, 9, 0, 0, 0, 9, 0, 0, 0, 10, -1, 0, 0, 0, 0, 11, 0, 9, 0, 0, 0, 0, 12, 0, 0, 0, 0, 10, 0, 0, 0, 0, -1, -1, 0, -1, 0, 0, -1, 14, 0, 0, 0, 0, -1, 0, 9, -1, 0, 13, 0, 0, 0, 0, 10, 12, 0, 0, 0, 0, 0, -1, 0, 0, 9, 0, 0, 0, 0, 0, 10, 10, 9, -1, 10, 0, 0, 9, 0, 9, 0, 0, 11, 9, -1, -1, 10, -1, 0, 0, -1, 0, -1, 0, 0, 14, 0, 0, -1, 0, 10, 10, 0, 0, 0, 0, 0, 0, 0, 0, 11, -1, 0, 0, 0, 0, 0, 0, -1, 0, -1, 0, 0, 0, 0, 0, 0, 9, -1, 0, 0, 0, 13, 0, 0, 0, 0, 10, 0, 0, 9, 0, -1, 0, -1, 9, 0, -1, 13, 0, 9, 10, 0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 11, 0, 10, -1, 0, -1, 0, 0, 13, 0, 13, 0, 9, 0, 9, 0, 0, -1, -1, 0, 0, 0, 0, 0, 10, -1, 0, 0, 0, -1, -1, 0, 0, 11, 13, 10, 0, 0, 12, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 14, 10, 0, 0, 0, 0, 0, -1, 0, 0, -1, 0, 0, 0, 11, 11, 0, 0, 14, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 0, -1, 10, 0, 0, 0, 0, -1, 0, 0, 0, 9, 0, 0, 0, 9, -1, 0, 0, 10, 0, 10, 0, 0, 0, 9, 0, 12, -1, 14, 0, 10, 0, 0, -1, 0, 0, 0, -1, 9, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, -1, 10, 0, 0, 9, 0, 0, 0, 0, 0, 11, 0, 10, 0, 0, -1, 15, 15, -1, -1, -1, 0, -1, 0, 0, 11, -1, 13, 0, -1, 0, 0, 9, 0, 0, 0, 0, 0, 0, -1, 9, 0, 0, 0, 0, 0, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, -1, 0, 0, -1, 0, 11, 0, 10, 0, -1, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 10, -1, -1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 13, 0, 9, 0, 15, 10, 11, 0, 9, 0, 0, 13, 9, 0, 0, 0, 9, 0, 0, -1, 10, 14, 0, 0, 0, 0, 11, 14, 0, 0, 0, 0, -1, 0, 0, 11, 9, -1, 0, 0, 0, 0, -1, 11, -1, 0, -1, 0, 0, 0, 0, 13, 13, 0, 0, 0, 0, 0, 0, 11, -1, 0, 0, 0, 0, 0, 0, -1, -1, 15, -1, 0, -1, 0, 0, 0, 11, 0, 0, 0, 0, -1, 0, 0, 0, 11, 15, 0, 0, 0, 0, 0, 0, 15, 0, 0, 0, 9, 0, 0, 11, 11, 11, -1, -1, 0, -1, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 0, 0, -1, 0, -1, 0, 0, 0, 0, 9, 0, -1, 0, 0, 15, 11, -1, 0, 0, 0, 0, 12, -1, 9, 0, -1, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, 0, 0, -1, 11, 0, -1, 0, -1, 0, 0, 0, -1, 0, 0, 11, 11, 0, 0, 0, 0, 9, 0, 9, 0, -1, 0, 0, 0, 11, 0, 0, 0, 14, 0, 0, 0, -1, 0, 0, 0, 0, 11, 0, 0, -1, 0, 0, -1, -1, 0, -1, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 11, 0, 0, 11, 0, 11, 0, 14, 0, 0, 0, 0, 11, -1, 0, 0, -1, 0, 13, 12, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 14, 0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 11, 0, 0, 11, 0, 0, 0, 0, 15, 11, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 15, 0, 0, 11, 11, 0, 11, 0, 0, 0, 0, 11, 9, 0, 0, 0, 9]

# has_illegal_adjacents() constants

const NEXUS_NODES_COUNT: int = 768
const NEXUS_ROW_SIZE: int = 16

const NEXUS_ADJACENTS_OFFSETS: Array[Array] = [
	[-32, -17, -16, 15, 16, 32], [-32, -16, -15, 16, 17, 32]
]

#endregion

# ..............................................................................

#region NEXUS RANDOMIZER

# randomizes empty nexus nodes with randomized stats types and stats qualities
func stats_nodes_randomizer() -> Array[Array]:
	var final_nexus_types: Array[int] = NEXUS_SET_TYPES.duplicate()
	var final_nexus_qualities: Array[int] = []

	final_nexus_qualities.resize(NEXUS_NODES_COUNT)

	# for each nexus area
	for area_index in NEXUS_AREA_COUNT:
		# initialize area nodes and area stats types populations
		var area_nodes: Array[int] = INITIAL_AREA_NODES[area_index].duplicate()
		var area_stats_types: Array[int] = set_area_stats_types(area_index, area_nodes.size())

		# distribute stats types nodes
		var failed_node_indices: Array[int] = []

		# for each nexus node
		for node_index in area_nodes:
			var remaining: int = area_stats_types.size()
			var failed_stats_types: Array[int] = []
			var stats_set_success: bool = false

			# attempt to set a stats type
			for index in remaining:
				# flip index to start from the last element of area_stats_types
				var flipped_index: int = remaining - 1 - index
				var attempt_stats_type: int = area_stats_types[flipped_index]

				# check attempted stats types
				if failed_stats_types.has(attempt_stats_type):
					continue

				# attempt stats type on the current node
				final_nexus_types[node_index] = attempt_stats_type

				# loop until the node finds a valid stats type
				if valid_node_option(final_nexus_types, node_index):
					stats_set_success = true
					area_stats_types.pop_at(flipped_index)
					break

				# record failed stats type
				failed_stats_types.append(attempt_stats_type)

			# catch failed allocation
			if not stats_set_success:
				failed_node_indices.push_back(node_index)

		# resolve failed node indices
		for node_index in failed_node_indices:
			var remaining: int = area_stats_types.size()

			# var swap_pool: Array = area_nodes[area_index]
			# var swap_target: int = randi() % remaining
			# var temp: int = area_stats_types[swap_target]
			# area_stats_types[swap_target] = area_stats_types[remaining - 1]
			# area_stats_types[remaining - 1] = temp

			final_nexus_types[node_index] = area_stats_types.pop_at(randi() % (remaining))

		var area_stats_qualities: Array[int] = AREA_STATS_QUALITIES_INDICES[area_index]

		for node_index in area_nodes:
			var stats_type: int = BASIC_STATS_TYPES_INDICES.find(final_nexus_types[node_index])
			if stats_type != -1:
				var a = STATS_TYPES_QUALITIES[stats_type][area_stats_qualities[stats_type]]
				var b = a[randi() % STATS_TYPES_QUALITIES[stats_type][area_stats_qualities[stats_type]].size()]
				final_nexus_qualities[node_index] = b

	return [final_nexus_types, final_nexus_qualities]

#endregion

# ..............................................................................

#region NEXUS UTILITIES

func set_area_stats_types(area_index: int, area_size: int) -> Array[int]:
	var area_stats_types: Array[int] = []

	# for each stats type
	for stats_type_index in BASIC_STATS_TYPES_COUNT:
		# randomize the number of a specific stats type
		var stats_type_count: int = BASE_AREA_STATS_COUNTS[area_index][stats_type_index]
		stats_type_count += round(
				STATS_COUNT_FLACTUATION_RATE[area_index][stats_type_index] * (
						randf_range(-0.25, 0.25) + randf_range(-0.25, 0.25)
						+ randf_range(-0.25, 0.25) + randf_range(-0.25, 0.25)))

		# populate area_stats_types
		for i in stats_type_count:
			area_stats_types.append(BASIC_STATS_TYPES_INDICES[stats_type_index])

	# populate remaining nodes with empty nodes & shuffle for randomized pairings
	area_stats_types.resize(area_size)
	area_stats_types.shuffle()

	return area_stats_types


# TODO: mediocre validations
# TODO: should handle cases with nexus board edges
func valid_node_option(nexus_types: Array[int], node_index: int) -> bool:
	var node_type: int = nexus_types[node_index]

	@warning_ignore("integer_division")
	var is_odd_row: bool = (node_index / NEXUS_ROW_SIZE) % 2 == 1

	# set adjacent indices
	for offset in NEXUS_ADJACENTS_OFFSETS[1 if is_odd_row else 0]:
		var adjacent_index: int = node_index + offset
		# valid index and shares node type with origin -> invalid
		if adjacent_index >= 0 and adjacent_index < NEXUS_NODES_COUNT:
			if node_type == nexus_types[adjacent_index]:
				return false

	# no adjacent node shares the same type as origin -> valid
	return true


func set_area_stats_qualities() -> Array[Array]:
	return []


#endregion

# ..............................................................................
