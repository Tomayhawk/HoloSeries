extends RefCounted

# Global.nexus_types
# -1: null
# 0: empty
# 1-8: HP, MP, DEF, WRD, STR, INT, SPD, AGI
# 9-11: special, white magic, black magic
# 12-15: diamond, clover, heart, spade

# Global.nexus_qualities
# -1 for all non-stats nodes

# ..............................................................................

#region NODE TYPES

enum NodeTypes {
	NULL = 0,
	EMPTY = 1 << 0,
	# stats
	HEALTH = 1 << 1,
	MANA = 1 << 2,
	DEFENCE = 1 << 3,
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
	ALL_STATS = HEALTH | MANA | DEFENCE | WARD | STRENGTH | INTELLIGENCE | SPEED | AGILITY,
	ALL_ABILITIES = SPECIAL | WHITE_MAGIC | BLACK_MAGIC,
	ALL_KEYS = DIAMOND | CLOVER | HEART | SPADE,
}

const STATS_TYPE_TO_INDEX: Dictionary[NodeTypes, int] = {
    NodeTypes.HEALTH: 0,
    NodeTypes.MANA: 1,
    NodeTypes.DEFENCE: 2,
    NodeTypes.WARD: 3,
    NodeTypes.STRENGTH: 4,
    NodeTypes.INTELLIGENCE: 5,
    NodeTypes.SPEED: 6,
    NodeTypes.AGILITY: 7,
}

const KEYS_TYPE_TO_INDEX: Dictionary[NodeTypes, int] = {
	NodeTypes.DIAMOND: 0,
	NodeTypes.CLOVER: 1,
	NodeTypes.HEART: 2,
	NodeTypes.SPADE: 3,
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
	DEFENCE,
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

#region ATLAS POSITIONS

const ATLAS_POSITIONS: Dictionary[NodeTypes, Vector2] = {
	NodeTypes.NULL: Vector2(32.0, 0.0),
	NodeTypes.EMPTY: Vector2(0.0, 0.0),
	# stats
	NodeTypes.HEALTH: Vector2(0.0, 32.0),
	NodeTypes.MANA: Vector2(32.0, 32.0),
	NodeTypes.DEFENCE: Vector2(64.0, 32.0),
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

# atlas positions for empty and null nodes
const EMPTY_ATLAS_POSITION: Vector2 = Vector2(0.0, 0.0)
const NULL_ATLAS_POSITION: Vector2 = Vector2(32.0, 0.0)

# atlas positions for HP, MP, DEF, WRD, STR, INT, SPD, AGI nodes
const STATS_ATLAS_POSITIONS: Array[Vector2] = [
	Vector2(0.0, 32.0),
	Vector2(32.0, 32.0),
	Vector2(64.0, 32.0),
	Vector2(96.0, 32.0),
	Vector2(0.0, 64.0),
	Vector2(32.0, 64.0),
	Vector2(64.0, 64.0),
	Vector2(96.0, 64.0),
]

# nexus nodes atlas positions for special, white magic, black magic nodes
const ABILITY_ATLAS_POSITIONS: Array[Vector2] = [
	Vector2(64.0, 0.0),
	Vector2(96.0, 0.0),
	Vector2(128.0, 0.0),
]

# atlas positions for diamond, clover, heart, spade key nodes
const KEY_ATLAS_POSITIONS: Array[Vector2] = [
	Vector2(0.0, 96.0),
	Vector2(32.0, 96.0),
	Vector2(64.0, 96.0),
	Vector2(96.0, 96.0)
]

#endregion

# ..............................................................................

#region MODULATE CONSTANTS

const NULL_MODULATE: Color = Color(0.2, 0.2, 0.2)
const KEY_MODULATE: Color = Color(0.33, 0.33, 0.33)
const LOCKED_MODULATE: Color = Color(0.25, 0.25, 0.25)
const UNLOCKED_MODULATE: Color = Color(1.0, 1.0, 1.0)

#endregion

# ..............................................................................

#region ATLAS POSITIONS

# converted stats qualities for HP, MP, DEF, WRD, STR, INT, SPD, AGI nodes
const CONVERTED_QUALITIES: Array[int] = [400, 40, 15, 15, 20, 20, 4, 4]

# adjacent node indices
const NEXUS_ROW_SIZE: int = 16
const NEXUS_ADJACENTS_OFFSETS: Array[Array] = [
	[-32, -17, -16, 15, 16, 32], [-32, -16, -15, 16, 17, 32]
]

#endregion

# ..............................................................................

#region TEXT BOX DESCRIPTIONS

const STATS_DESCRIPTION_BASE: String = "Gain %s %s."

const NODE_DESCRIPTIONS: Dictionary[NodeTypes, String] = {

}

const STATS_DESCRIPTIONS: Array[String] = [
	"HP",
	"MP",
	"Defense",
	"Ward",
	"Strength",
	"Intelligence",
	"Speed",
	"Agility",
]

const KEY_DESCRIPTIONS: Array[String] = [
	"Star",
	"Prosperity",
	"Love",
	"Nobility",
]

const ABILITY_DESCRIPTIONS: Array[String] = [
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
]

const ITEM_NAMES: Array[String] = [
	# Life, Magic and Reflex
	"Life",
	"Magic",
	"Reflex",
	# Special, Blessed, Abyssal
	"Special",
	"Blessed",
	"Abyssal",
	# Star, Prosperity, Love, Nobility
	"Star",
	"Prosperity",
	"Love",
	"Nobility",
	# Sunlight, Starlight, Moonlight
	"Sunlight",
	"Starlight",
	"Moonlight",
	# Dream, Return, Share and Instant
	"Dream",
	"Return",
	"Share",
	"Instant",
	# Health, Mana, Defense, Ward, Strength, Intelligence, Speed, Agility
	"Health",
	"Mana",
	"Defense",
	"Ward",
	"Strength",
	"Intelligence",
	"Speed",
	"Agility",
	# Clear
	"Clear",
]

const ITEM_DESCRIPTIONS: Array[String] = [
	# Life, Magic and Reflex
	"Unlocks a Health, Defence or Strength node.",
	"Unlocks a Magic, Ward or Intelligence node.",
	"Unlocks a Speed or Agility node.",
	# Special, Blessed, Abyssal
	"Unlocks a Special node.",
	"Unlocks a White Magic node.",
	"Unlocks a Black Magic node.",
	# Star, Prosperity, Love, Nobility
	"Unlocks a Diamond Key node.",
	"Unlocks a Clover Key node.",
	"Unlocks a Heart Key node.",
	"Unlocks a Spade Key node.",
	# Sunlight, Starlight, Moonlight
	"Unlocks any Special node on the board.",
	"Unlocks any White Magic node on the board.",
	"Unlocks any Black Magic node on the board.",
	# Dream, Return, Share and Instant
	"Unlocks any one node on the board.",
	"Teleports this character to any of their unlocked nodes.",
	"Teleports this character to any other character's current node.",
	"Teleports this character to any node on the board.",
	# Health, Mana, Defense, Ward, Strength, Intelligence, Speed, Agility
	"Converts an Empty node into an Health node.",
	"Converts an Empty node into an Magic node.",
	"Converts an Empty node into a Defence node.",
	"Converts an Empty node into a Ward node.",
	"Converts an Empty node into an Strength node.",
	"Converts an Empty node into an Intelligence node.",
	"Converts an Empty node into a Speed node.",
	"Converts an Empty node into an Agility node.",
	# Clear
	"Converts a Stats node into an Empty node.",
]

# -1: null
# 0: empty
# 1-8: HP, MP, DEF, WRD, STR, INT, SPD, AGI
# 9-11: special, white magic, black magic
# 12-15: diamond, clover, heart, spade

const ITEM_COMPATIBLES : Array[int] = [
	# Life, Magic and Reflex
	NodeTypes.HEALTH | NodeTypes.DEFENCE | NodeTypes.STRENGTH,
	NodeTypes.MANA | NodeTypes.WARD | NodeTypes.INTELLIGENCE,
	NodeTypes.SPEED | NodeTypes.AGILITY,
	# Special, Blessed, Abyssal
	NodeTypes.SPECIAL,
	NodeTypes.WHITE_MAGIC,
	NodeTypes.BLACK_MAGIC,
	# Star, Prosperity, Love, Nobility
	NodeTypes.DIAMOND,
	NodeTypes.CLOVER,
	NodeTypes.HEART,
	NodeTypes.SPADE,
	# Sunlight, Starlight, Moonlight
	NodeTypes.SPECIAL,
	NodeTypes.WHITE_MAGIC,
	NodeTypes.BLACK_MAGIC,
	# Dream, Return, Share and Instant - all non-null types
	NodeTypes.ALL,
	NodeTypes.ALL,
	NodeTypes.ALL,
	NodeTypes.ALL,
	# Health, Mana, Defense, Ward, Strength, Intelligence, Speed, Agility
	NodeTypes.EMPTY,
	NodeTypes.EMPTY,
	NodeTypes.EMPTY,
	NodeTypes.EMPTY,
	NodeTypes.EMPTY,
	NodeTypes.EMPTY,
	NodeTypes.EMPTY,
	NodeTypes.EMPTY,
	# Clear
	NodeTypes.ALL_STATS,
]

#endregion

# ..............................................................................
