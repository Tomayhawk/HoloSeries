extends RefCounted

# ..............................................................................

#region NODE TYPES

enum NodeTypes {
	NULL = 0,
	EMPTY = 1 << 0,
	# stats
	HEALTH = 1 << 1,
	MANA = 1 << 2,
	DEFENSE = 1 << 3,
	WARD = 1 << 4,
	STRENGTH = 1 << 5,
	INTELLIGENCE = 1 << 6,
	SPEED = 1 << 7,
	AGILITY = 1 << 8,
	# abilities
	SPECIAL = 1 << 9,
	WHITE_MAGIC = 1 << 10,
	BLACK_MAGIC = 1 << 11,
	# keys
	DIAMOND = 1 << 12,
	CLOVER = 1 << 13,
	HEART = 1 << 14,
	SPADE = 1 << 15,
	# combinations
	ALL = 0xFFFFFFFF,
	ALL_STATS = HEALTH | MANA | DEFENSE | WARD | STRENGTH | INTELLIGENCE | SPEED | AGILITY,
	ALL_ABILITIES = SPECIAL | WHITE_MAGIC | BLACK_MAGIC,
	ALL_KEYS = DIAMOND | CLOVER | HEART | SPADE,
}

#endregion

# ..............................................................................

#region CRYSTAL TYPES

enum CrystalTypes {
	# unlocks stats
	LIFE,
	MAGIC,
	REFLEX,
	# unlocks abilities
	SPECIAL,
	BLESSED,
	ABYSSAL,
	# unlocks keys
	STAR,
	PROSPERITY,
	LOVE,
	NOBILITY,
	# unlocks abilities (boardwide)
	SUNLIGHT,
	STARLIGHT,
	MOONLIGHT,
	# dream, return, share and instant
	DREAM,
	RETURN,
	SHARE,
	INSTANT,
	# converts empty into stats
	HEALTH,
	MANA,
	DEFENSE,
	WARD,
	STRENGTH,
	INTELLIGENCE,
	SPEED,
	AGILITY,
	# converts stats into empty
	CLEAR,
}

#endregion

# ..............................................................................

#region NEXUS BOARD CONSTANTS

const NEXUS_NODES_COUNT: int = 768
const NEXUS_ROW_SIZE: int = 16

const NEXUS_ADJACENTS_OFFSETS: Array[Array] = [
	[-32, -17, -16, 15, 16, 32], [-32, -16, -15, 16, 17, 32]
]

# modulate constants
const NULL_MODULATE: Color = Color(0.2, 0.2, 0.2, 1.0)
const KEY_MODULATE: Color = Color(0.33, 0.33, 0.33, 1.0)
const LOCKED_MODULATE: Color = Color(0.25, 0.25, 0.25, 1.0)
const UNLOCKED_MODULATE: Color = Color(1.0, 1.0, 1.0, 1.0)

#endregion

# ..............................................................................

#region NODE DICTIONARIES

const ATLAS_POSITIONS: Dictionary[NodeTypes, Vector2] = {
	NodeTypes.NULL: Vector2(32.0, 0.0),
	NodeTypes.EMPTY: Vector2(0.0, 0.0),
	# stats
	NodeTypes.HEALTH: Vector2(0.0, 32.0),
	NodeTypes.MANA: Vector2(32.0, 32.0),
	NodeTypes.DEFENSE: Vector2(64.0, 32.0),
	NodeTypes.WARD: Vector2(96.0, 32.0),
	NodeTypes.STRENGTH: Vector2(0.0, 64.0),
	NodeTypes.INTELLIGENCE: Vector2(32.0, 64.0),
	NodeTypes.SPEED: Vector2(64.0, 64.0),
	NodeTypes.AGILITY: Vector2(96.0, 64.0),
	# abilities
	NodeTypes.SPECIAL: Vector2(64.0, 0.0),
	NodeTypes.WHITE_MAGIC: Vector2(96.0, 0.0),
	NodeTypes.BLACK_MAGIC: Vector2(128.0, 0.0),
	# keys
	NodeTypes.DIAMOND: Vector2(0.0, 96.0),
	NodeTypes.CLOVER: Vector2(32.0, 96.0),
	NodeTypes.HEART: Vector2(64.0, 96.0),
	NodeTypes.SPADE: Vector2(96.0, 96.0),
}

const NODE_DESCRIPTIONS: Dictionary[NodeTypes, String] = {
	NodeTypes.NULL: "Null Node.",
	NodeTypes.EMPTY: "Empty Node.",
	# stats
	NodeTypes.HEALTH: "Gain %s HP.",
	NodeTypes.MANA: "Gain %s MP.",
	NodeTypes.DEFENSE: "Gain %s Defense.",
	NodeTypes.WARD: "Gain %s Ward.",
	NodeTypes.STRENGTH: "Gain %s Strength.",
	NodeTypes.INTELLIGENCE: "Gain %s Intelligence.",
	NodeTypes.SPEED: "Gain %s Speed.",
	NodeTypes.AGILITY: "Gain %s Agility.",
	# abilities
	NodeTypes.SPECIAL: "Unlock %s.",
	NodeTypes.WHITE_MAGIC: "Unlock %s.",
	NodeTypes.BLACK_MAGIC: "Unlock %s.",
	# keys
	NodeTypes.DIAMOND: "Requires a Star Key to Unlock.",
	NodeTypes.CLOVER: "Requires a Prosperity Key to Unlock.",
	NodeTypes.HEART: "Requires a Love Key to Unlock.",
	NodeTypes.SPADE: "Requires a Nobility Key to Unlock.",
}

# converted stats qualities
const CONVERTED_QUALITIES: Dictionary[NodeTypes, int] = {
	NodeTypes.EMPTY: 0,
	NodeTypes.HEALTH: 400,
	NodeTypes.MANA: 40,
	NodeTypes.DEFENSE: 15,
	NodeTypes.WARD: 15,
	NodeTypes.STRENGTH: 20,
	NodeTypes.INTELLIGENCE: 20,
	NodeTypes.SPEED: 4,
	NodeTypes.AGILITY: 4,
}

const ABILITY_NAMES: Array[String] = [
	"Play Dice",
]

#endregion

# ..............................................................................

#region CRYSTAL DICTIONARIES

const CRYSTAL_NAMES: Dictionary[CrystalTypes, String] = {
	# Life, Magic and Reflex
	CrystalTypes.LIFE: "Life",
	CrystalTypes.MAGIC: "Magic",
	CrystalTypes.REFLEX: "Reflex",
	# Special, Blessed, Abyssal
	CrystalTypes.SPECIAL: "Special",
	CrystalTypes.BLESSED: "Blessed",
	CrystalTypes.ABYSSAL: "Abyssal",
	# Star, Prosperity, Love, Nobility
	CrystalTypes.STAR: "Star",
	CrystalTypes.PROSPERITY: "Prosperity",
	CrystalTypes.LOVE: "Love",
	CrystalTypes.NOBILITY: "Nobility",
	# Sunlight, Starlight, Moonlight
	CrystalTypes.SUNLIGHT: "Sunlight",
	CrystalTypes.STARLIGHT: "Starlight",
	CrystalTypes.MOONLIGHT: "Moonlight",
	# Dream, Return, Share and Instant
	CrystalTypes.DREAM: "Dream",
	CrystalTypes.RETURN: "Return",
	CrystalTypes.SHARE: "Share",
	CrystalTypes.INSTANT: "Instant",
	# Health, Mana, Defense, Ward, Strength, Intelligence, Speed, Agility
	CrystalTypes.HEALTH: "Health",
	CrystalTypes.MANA: "Mana",
	CrystalTypes.DEFENSE: "Defense",
	CrystalTypes.WARD: "Ward",
	CrystalTypes.STRENGTH: "Strength",
	CrystalTypes.INTELLIGENCE: "Intelligence",
	CrystalTypes.SPEED: "Speed",
	CrystalTypes.AGILITY: "Agility",
	# Clear
	CrystalTypes.CLEAR: "Clear",
}

const CRYSTAL_DESCRIPTIONS: Dictionary[CrystalTypes, String] = {
	# Life, Magic and Reflex
	CrystalTypes.LIFE: "Unlocks a Health, Defense or Strength node.",
	CrystalTypes.MAGIC: "Unlocks a Magic, Ward or Intelligence node.",
	CrystalTypes.REFLEX: "Unlocks a Speed or Agility node.",
	# Special, Blessed, Abyssal
	CrystalTypes.SPECIAL: "Unlocks a Special node.",
	CrystalTypes.BLESSED: "Unlocks a White Magic node.",
	CrystalTypes.ABYSSAL: "Unlocks a Black Magic node.",
	# Star, Prosperity, Love, Nobility
	CrystalTypes.STAR: "Unlocks a Diamond Key node.",
	CrystalTypes.PROSPERITY: "Unlocks a Clover Key node.",
	CrystalTypes.LOVE: "Unlocks a Love Key node.",
	CrystalTypes.NOBILITY: "Unlocks a Nobility Key node.",
	# Sunlight, Starlight, Moonlight
	CrystalTypes.SUNLIGHT: "Unlocks any Special node on the board.",
	CrystalTypes.STARLIGHT: "Unlocks any White Magic node on the board.",
	CrystalTypes.MOONLIGHT: "Unlocks any Black Magic node on the board.",
	# Dream, Return, Share and Instant
	CrystalTypes.DREAM: "Unlocks any one node on the board.",
	CrystalTypes.RETURN: "Teleports this character to any of their unlocked nodes.",
	CrystalTypes.SHARE: "Teleports this character to any other character's current node.",
	CrystalTypes.INSTANT: "Teleports this character to any node on the board.",
	# Health, Mana, Defense, Ward, Strength, Intelligence, Speed, Agility
	CrystalTypes.HEALTH: "Converts an Empty node into an Health node.",
	CrystalTypes.MANA: "Converts an Empty node into an Magic node.",
	CrystalTypes.DEFENSE: "Converts an Empty node into a Defense node.",
	CrystalTypes.WARD: "Converts an Empty node into a Ward node.",
	CrystalTypes.STRENGTH: "Converts an Empty node into an Strength node.",
	CrystalTypes.INTELLIGENCE: "Converts an Empty node into an Intelligence node.",
	CrystalTypes.SPEED: "Converts an Empty node into a Speed node.",
	CrystalTypes.AGILITY: "Converts an Empty node into an Agility node.",
	# Clear
	CrystalTypes.CLEAR: "Converts a Stats node into an Empty node.",
}

const CRYSTAL_COMPATIBLES : Dictionary[CrystalTypes, int] = {
	# Life, Magic and Reflex
	CrystalTypes.LIFE: NodeTypes.HEALTH | NodeTypes.DEFENSE | NodeTypes.STRENGTH,
	CrystalTypes.MAGIC: NodeTypes.MANA | NodeTypes.WARD | NodeTypes.INTELLIGENCE,
	CrystalTypes.REFLEX: NodeTypes.SPEED | NodeTypes.AGILITY,
	# Special, Blessed, Abyssal
	CrystalTypes.SPECIAL: NodeTypes.SPECIAL,
	CrystalTypes.BLESSED: NodeTypes.WHITE_MAGIC,
	CrystalTypes.ABYSSAL: NodeTypes.BLACK_MAGIC,
	# Star, Prosperity, Love, Nobility
	CrystalTypes.STAR: NodeTypes.DIAMOND,
	CrystalTypes.PROSPERITY: NodeTypes.CLOVER,
	CrystalTypes.LOVE: NodeTypes.HEART,
	CrystalTypes.NOBILITY: NodeTypes.SPADE,
	# Sunlight, Starlight, Moonlight
	CrystalTypes.SUNLIGHT: NodeTypes.SPECIAL,
	CrystalTypes.STARLIGHT: NodeTypes.WHITE_MAGIC,
	CrystalTypes.MOONLIGHT: NodeTypes.BLACK_MAGIC,
	# Dream, Return, Share and Instant - all non-null types
	CrystalTypes.DREAM: NodeTypes.ALL,
	CrystalTypes.RETURN: NodeTypes.ALL,
	CrystalTypes.SHARE: NodeTypes.ALL,
	CrystalTypes.INSTANT: NodeTypes.ALL,
	# Health, Mana, Defense, Ward, Strength, Intelligence, Speed, Agility
	CrystalTypes.HEALTH: NodeTypes.EMPTY,
	CrystalTypes.MANA: NodeTypes.EMPTY,
	CrystalTypes.DEFENSE: NodeTypes.EMPTY,
	CrystalTypes.WARD: NodeTypes.EMPTY,
	CrystalTypes.STRENGTH: NodeTypes.EMPTY,
	CrystalTypes.INTELLIGENCE: NodeTypes.EMPTY,
	CrystalTypes.SPEED: NodeTypes.EMPTY,
	CrystalTypes.AGILITY: NodeTypes.EMPTY,
	# Clear
	CrystalTypes.CLEAR: NodeTypes.ALL_STATS,
}

#endregion

# ..............................................................................

#region UTILITIES

static func set_nexus_stats(player_stats: PlayerStats) -> Array[float]:
	const STATS_TYPE_TO_INDEX: Dictionary[NodeTypes, int] = {
		NodeTypes.HEALTH: 0,
		NodeTypes.MANA: 1,
		NodeTypes.DEFENSE: 2,
		NodeTypes.WARD: 3,
		NodeTypes.STRENGTH: 4,
		NodeTypes.INTELLIGENCE: 5,
		NodeTypes.SPEED: 6,
		NodeTypes.AGILITY: 7,
	}

	# get converted nodes and types
	var converted_nodes: Array[int] = []
	var converted_types: Array[int] = []
	for converted in player_stats.converted_nodes:
		converted_nodes.append(converted.x)
		converted_types.append(converted.y)

	# accumulate all nexus stats
	var nexus_stats: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	for node_index in player_stats.unlocked_nodes:
		var node_type: int = Global.nexus_types[node_index]
		var converted_type: int = -1 if converted_types.is_empty() else converted_types[converted_nodes.find(node_index)]
		if converted_type != -1:
			nexus_stats[STATS_TYPE_TO_INDEX[converted_type]] += CONVERTED_QUALITIES[converted_type]
		elif node_type & NodeTypes.ALL_STATS:
			nexus_stats[STATS_TYPE_TO_INDEX[node_type]] += Global.nexus_qualities[node_index]

	return nexus_stats

#endregion

# ..............................................................................
