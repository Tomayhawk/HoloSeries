class_name Manager extends RefCounted

# MANAGER

# ..............................................................................

#region ENUMS

enum BlockType {
	# jump
	JUMP = 0,					# BlockType.JUMP, JUMP_SIZE     OR     BlockType.JUMP, 0, X, Y

	# control
	IF = 1 << 0,				# BlockType.IF, CONDITION_SIZE, CONTENT_SIZE, [CONDITION], [CONTENT]
	ELSE = 1 << 1,				# BlockType.ELSE, CONDITION_SIZE, CONTENT_SIZE_1, [CONDITION], [CONTENT_1], BlockType.JUMP, JUMP_SIZE, [CONTENT_2]
	ELIF = 1 << 2,				# BlockType.ELIF, CONDITION_SIZE_1, CONTENT_SIZE_1, CONDITION_SIZE_2, CONTENT_SIZE_2, [CONDITION_1], [CONTENT_1], BlockType.JUMP, JUMP_INDEX, [CONDITION_2], [CONTENT_2], BlockType.JUMP, JUMP_INDEX, [CONTENT_3]
	WHEN = 1 << 3,				# BlockType.WHEN, CONDITION_SIZE, CONTENT_SIZE, [CONDITION], [CONTENT]

	# action
	ATTACK = 1 << 4,
	ABILITY = 1 << 5,
	WHITE = 1 << 6,
	BLACK = 1 << 7,
	SUMMON = 1 << 8,
	ITEMS = 1 << 9,

	# operator
	LESS_THAN = 1 << 10,		# BlockType.LESS_THAN, LEFT_SIZE, [LEFT_VARIABLE], [RIGHT_VARIABLE]
	EQUALS = 1 << 11,			# BlockType.EQUALS, LEFT_SIZE, [LEFT_VARIABLE], [RIGHT_VARIABLE]
	GREATER_THAN = 1 << 12,		# BlockType.GREATER_THAN, LEFT_SIZE, [LEFT_VARIABLE], [RIGHT_VARIABLE]
	AND = 1 << 13,				# BlockType.AND, LEFT_SIZE, [LEFT_VARIABLE], [RIGHT_VARIABLE]
	OR = 1 << 14,				# BlockType.OR, LEFT_SIZE, [LEFT_VARIABLE], [RIGHT_VARIABLE]
	NOT = 1 << 15,				# BlockType.NOT, [CONDITION]
	HAS_STATUS = 1 << 16,		# BlockType.HAS_STATUS, Entities.Status, [TARGET_VARIABLE]

	# variable
	TARGET = 1 << 17,			# BlockType.TARGET, TargetType, StatType     OR     BlockType.TARGET, TargetType.ALLY_SPECIFIC, CHARACTER_INDEX, StatType
	NUMBER = 1 << 18,			# BlockType.NUMBER, NUMBER

	# tag
	TAG = 1 << 19,

	# special
	SPECIAL = 1 << 20, # TODO: NOT IMPLEMENTED YET
}

enum TargetType {
	SELF,
	ALLY_SPECIFIC,
	ALLY_LEAST,
	ALLY_MOST,
	ALLY_ANY,
	ALLY_WITH_EFFECT,
	ENEMY_LOCKED,
	ENEMY_LEAST,
	ENEMY_MOST,
	ENEMY_ANY,
	ENEMY_WITH_EFFECT,
}

enum StatType {
	HEALTH,
	HEALTH_PERCENTAGE,
	MANA,
	MANA_PERCENTAGE,
	STAMINA,
	STAMINA_PERCENTAGE,
	SHIELD,
	DEFENSE,
	WARD,
	STRENGTH,
	INTELLIGENCE,
	SPEED,
	AGILITY,
	CRIT_CHANCE,
	CRIT_DAMAGE,
	FORCE,
	WEIGHT,
	VISION,
}

enum NumberType {
	NUMBER,
	PERCENTAGE,
}

#endregion

# ..............................................................................

#region CONSTANTS

const CONTENT_BLOCKS: int = (
		CONTROL_BLOCKS
		| ACTION_BLOCKS
)

const CONTROL_BLOCKS: int = (
		BlockType.IF
		| BlockType.ELSE
		| BlockType.ELIF
		| BlockType.WHEN
)

const ACTION_BLOCKS: int = (
		BlockType.ATTACK
		| BlockType.ABILITY
		| BlockType.WHITE
		| BlockType.BLACK
		| BlockType.SUMMON
		| BlockType.ITEMS
)

const OPERATOR_BLOCKS: int = (
		BlockType.LESS_THAN
		| BlockType.EQUALS
		| BlockType.GREATER_THAN
		| BlockType.AND
		| BlockType.OR
		| BlockType.NOT
		| BlockType.HAS_STATUS
)

const COMPARATOR_BLOCKS: int = (
		BlockType.LESS_THAN
		| BlockType.GREATER_THAN
		| BlockType.EQUALS
)

const LOGIC_BLOCKS: int = (
		BlockType.AND
		| BlockType.OR
		| BlockType.NOT
)

const VARIABLE_BLOCKS: int = (
		BlockType.TARGET
		| BlockType.NUMBER
)

const STAT_NAMES: Dictionary[StatType, StringName] = {
	StatType.HEALTH: &"health",
	StatType.HEALTH_PERCENTAGE: &"health_percentage",
	StatType.MANA: &"mana",
	StatType.MANA_PERCENTAGE: &"mana_percentage",
	StatType.STAMINA: &"stamina",
	StatType.STAMINA_PERCENTAGE: &"stamina_percentage",
	StatType.SHIELD: &"shield",
	StatType.DEFENSE: &"defense",
	StatType.WARD: &"ward",
	StatType.STRENGTH: &"strength",
	StatType.INTELLIGENCE: &"intelligence",
	StatType.SPEED: &"speed",
	StatType.AGILITY: &"agility",
	StatType.CRIT_CHANCE: &"crit_chance",
	StatType.CRIT_DAMAGE: &"crit_damage",
	StatType.FORCE: &"force",
	StatType.WEIGHT: &"weight",
	StatType.VISION: &"vision",
}

#endregion

# ..............................................................................

#region ACTION DECODER

# each layout starts with the non_when_start_index
# each major cluster starts with BlockType.JUMP, 0, X, Y
# X, Y stores the float binary for the position of the cluster
# all when clusters are at the front of the layout

static func get_next_action_index(stats: PlayerStats) -> int:
	var layout: PackedInt32Array = stats.manager_layouts[stats.current_manager_layout]
	var tree_size: int = layout.size()
	var tree_index: int = 1

	# start with when blocks
	var non_when_start_index: int = layout[0]

	# set last action index 0 if is -1
	var last_action_index: int = max(0, stats.current_action_index)
	var inside_last_cluster: bool = false

	while tree_index < tree_size:
		if last_action_index and non_when_start_index and tree_index == non_when_start_index:
			tree_index = last_action_index
			last_action_index = 0
			inside_last_cluster = true

		match layout[tree_index]:
			# BlockType.JUMP, JUMP_SIZE     OR     BlockType.JUMP, 0, X, Y
			BlockType.JUMP:
				if layout[tree_index + 1]:
					tree_index += layout[tree_index + 1]
				elif inside_last_cluster:
					inside_last_cluster = false
					tree_index = non_when_start_index
				else:
					tree_index += 4

			# BlockType.WHEN, CONDITION_SIZE, CONTENT_SIZE, [CONDITION], [CONTENT]
			# BlockType.IF, CONDITION_SIZE, CONTENT_SIZE, [CONDITION], [CONTENT]
			# BlockType.ELSE, CONDITION_SIZE, CONTENT_SIZE_1, [CONDITION], [CONTENT_1], BlockType.JUMP, JUMP_SIZE, [CONTENT_2]
			BlockType.WHEN, BlockType.IF, BlockType.ELSE:
				var condition_size: int = layout[tree_index + 1]
				var content_size: int = layout[tree_index + 2]

				tree_index += 3

				if evaluate_condition(stats, tree_index):
					tree_index += condition_size
				else:
					tree_index += condition_size + content_size

			# BlockType.ELIF, CONDITION_SIZE_1, CONTENT_SIZE_1, CONDITION_SIZE_2, CONTENT_SIZE_2, [CONDITION_1], [CONTENT_1], BlockType.JUMP, JUMP_INDEX, [CONDITION_2], [CONTENT_2], BlockType.JUMP, JUMP_INDEX, [CONTENT_3]
			BlockType.ELIF:
				var condition_size_1: int = layout[tree_index + 1]
				var content_size_1: int = layout[tree_index + 2]
				var condition_size_2: int = layout[tree_index + 3]
				var content_size_2: int = layout[tree_index + 4]

				tree_index += 5

				if evaluate_condition(stats, tree_index):
					tree_index += condition_size_1
				elif evaluate_condition(stats, tree_index + condition_size_1 + content_size_1):
					tree_index += condition_size_1 + content_size_1 + condition_size_2
				else:
					tree_index += condition_size_1 + content_size_1 + condition_size_2 + content_size_2

			_: # action
				return tree_index

	# default to basic attack
	return -1

#endregion

# ..............................................................................

#region CONDITION DECODER

static func evaluate_condition(stats: PlayerStats, index: int) -> bool:
	var layout: PackedInt32Array = stats.manager_layouts[stats.current_manager_layout]
	var operator: int = layout[index]

	# BlockType.NOT, [CONDITION]
	if operator == BlockType.NOT:
		return not evaluate_condition(stats, index + 1)

	# BlockType.HAS_STATUS, Entities.Status, [TARGET_VARIABLE]
	if operator == BlockType.HAS_STATUS:
		return evaluate_status_condition(stats, index + 1)

	# BlockType.LESS_THAN, LEFT_SIZE, [LEFT_VARIABLE], [RIGHT_VARIABLE]
	# BlockType.EQUALS, LEFT_SIZE, [LEFT_VARIABLE], [RIGHT_VARIABLE]
	# BlockType.GREATER_THAN, LEFT_SIZE, [LEFT_VARIABLE], [RIGHT_VARIABLE]
	if operator & COMPARATOR_BLOCKS:
		return evaluate_comparison(stats, index)

	# BlockType.AND, LEFT_SIZE, [LEFT_VARIABLE], [RIGHT_VARIABLE]
	# BlockType.OR, LEFT_SIZE, [LEFT_VARIABLE], [RIGHT_VARIABLE]
	var left_size: int = layout[index + 1]
	var left_condition: bool = evaluate_condition(stats, index + 2)
	var right_condition: bool = evaluate_condition(stats, index + 2 + left_size)

	return (left_condition and right_condition) if operator == BlockType.AND else (left_condition or right_condition)


# BlockType.HAS_STATUS, Entities.Status, [TARGET_VARIABLE]
static func evaluate_status_condition(stats: PlayerStats, index: int) -> bool:
	var layout: PackedInt32Array = stats.manager_layouts[stats.current_manager_layout]
	var status: Entities.Status = layout[index] as Entities.Status

	match layout[index + 1]:
		TargetType.SELF:
			return stats.has_status(status)

		# TargetType.ALLY_SPECIFIC, CHARACTER_INDEX
		TargetType.ALLY_SPECIFIC:
			var player_base: PlayerBase = \
					get_player_base_by_character_index(layout[index + 2])
			return player_base and player_base.stats.has_status(status)

		TargetType.ALLY_ANY:
			for player_base in Players.party_bases:
				if is_instance_valid(player_base) and player_base.stats.has_status(status):
					return true

		TargetType.ENEMY_LOCKED:
			return is_instance_valid(Combat.locked_enemy_base) and Combat.locked_enemy_base.stats.has_status(status)

		TargetType.ENEMY_ANY:
			for enemy_base in Entities_.all_enemies():
				if is_instance_valid(enemy_base) and enemy_base.stats.has_status(status):
					return true

	return false


# BlockType.LESS_THAN, LEFT_SIZE, [LEFT_VARIABLE], [RIGHT_VARIABLE]
# BlockType.EQUALS, LEFT_SIZE, [LEFT_VARIABLE], [RIGHT_VARIABLE]
# BlockType.GREATER_THAN, LEFT_SIZE, [LEFT_VARIABLE], [RIGHT_VARIABLE]
static func evaluate_comparison(stats: PlayerStats, index: int) -> bool:
	var layout: PackedInt32Array = stats.manager_layouts[stats.current_manager_layout]

	var comparator: BlockType = layout[index] as BlockType
	var left_values: Array[float] = append_variable_values(stats, index + 2)
	var right_values: Array[float] = append_variable_values(stats, index + 2 + layout[index + 1])

	# check comparisons
	for left_value in left_values:
		for right_value in right_values:
			var comparison_passed: bool = false

			match comparator:
				BlockType.LESS_THAN:
					comparison_passed = left_value < right_value
				BlockType.EQUALS:
					comparison_passed = is_equal_approx(left_value, right_value)
				_: # BlockType.GREATER_THAN
					comparison_passed = left_value > right_value

			if comparison_passed:
				return true

	return false


static func append_variable_values(stats: PlayerStats, index: int) -> Array[float]:
	var layout: PackedInt32Array = stats.manager_layouts[stats.current_manager_layout]

	# BlockType.NUMBER, NumberType, NUMBER
	if layout[index] & BlockType.NUMBER:
		if layout[index] == NumberType.PERCENTAGE:
			return [float(layout[index + 2]) / 100.0]

		return [float(layout[index + 2])]

	# BlockType.TARGET

	# multi target type
	if layout[index + 1] in [TargetType.ALLY_ANY, TargetType.ENEMY_ANY]:
		return multi_target_stats(stats, index + 1)

	# single target type
	var value: float = single_target_stat(stats, index + 1)

	return [] if is_equal_approx(value, -1.0) else [value]


static func multi_target_stats(stats: PlayerStats, index: int) -> Array[float]:
	var layout: PackedInt32Array = stats.manager_layouts[stats.current_manager_layout]
	var target_stats_array: Array[float] = []
	var stat_name: StringName = STAT_NAMES[layout[index + 1]]

	# TargetType.X, StatType
	match layout[index]:
		TargetType.ALLY_ANY:
			for player_base in Players.party_bases:
				if is_instance_valid(player_base):
					target_stats_array.append(player_base.stats.get(stat_name))

		TargetType.ENEMY_ANY:
			for enemy_base in Entities_.all_enemies():
				target_stats_array.append(enemy_base.stats.get(stat_name))

	return target_stats_array


static func single_target_stat(stats: PlayerStats, index: int) -> float:
	var layout: PackedInt32Array = stats.manager_layouts[stats.current_manager_layout]

	# TargetType.ALLY_SPECIFIC, CHARACTER_INDEX, StatType
	if layout[index] == TargetType.ALLY_SPECIFIC:
		var player_base: PlayerBase = \
				get_player_base_by_character_index(layout[index + 1])
		return -1.0 if not player_base else player_base.stats.get(STAT_NAMES[layout[index + 2]])

	var target_base: EntityBase = null
	var stat_name: StringName = STAT_NAMES[layout[index + 1]]

	# TargetType.X, StatType
	match layout[index]:
		TargetType.SELF:
			return stats.get(stat_name)

		TargetType.ALLY_LEAST:
			target_base = Entities_.target_entity_by_stats(
					Entities_.type_entities_array(Players.party_bases), stat_name, false)

		TargetType.ALLY_MOST:
			target_base = Entities_.target_entity_by_stats(
					Entities_.type_entities_array(Players.party_bases), stat_name, true)

		TargetType.ENEMY_LOCKED:
			target_base = Combat.locked_enemy_base

		TargetType.ENEMY_LEAST:
			target_base = Entities_.target_entity_by_stats(
					Entities_.all_enemies(), stat_name, false)

		TargetType.ENEMY_MOST:
			target_base = Entities_.target_entity_by_stats(
					Entities_.all_enemies(), stat_name, true)

	return -1.0 if not is_instance_valid(target_base) else target_base.stats.get(stat_name)


static func get_player_base_by_character_index(character_index: int) -> PlayerBase:
	for player_base in Players.party_bases:
		if (is_instance_valid(player_base)
				and player_base.stats.CHARACTER_INDEX == character_index):
			return player_base

	return null

#endregion

# ..............................................................................

#region ACTION EXECUTION

static func get_entity_base_by_status(entity_bases: Array[EntityBase], status: Entities.Status) -> EntityBase:
	# returns the first entity base with a specific status
	for entity_base in entity_bases:
		if entity_base.stats.has_status(status):
			return entity_base

	return null

#endregion

# ..............................................................................
