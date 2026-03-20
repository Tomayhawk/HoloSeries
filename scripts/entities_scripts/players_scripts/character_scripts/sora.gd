extends PlayerStats

# SORA (CHARACTER)

# Score: 4.55
# Buffer - Healer

# ..............................................................................

#region CONSTANTS

# name, index
const CHARACTER_NAME: String = "Tokino Sora"
const CHARACTER_INDEX: int = 0

# health, mana, stamina (debug values)
const CHARACTER_HEALTH: float = 9999.0 # +190 (+0.95 T1)
const CHARACTER_MANA: float = 999.0 # +18 (+1.8 T1)
const CHARACTER_STAMINA: float = 999.0

# basic stats (debug values)
const CHARACTER_DEFENSE: float = 999.0
const CHARACTER_WARD: float = 999.0
const CHARACTER_STRENGTH: float = 999.0
const CHARACTER_INTELLIGENCE: float = 999.0 # +4 (+0.8 T1)
const CHARACTER_SPEED: float = 255.0 # +1 (+1 T1)
const CHARACTER_AGILITY: float = 255.0 # +1 (+1 T1)
const CHARACTER_CRIT_CHANCE: float = 0.50
const CHARACTER_CRIT_DAMAGE: float = 1.50

# nexus
const CHARACTER_DEFAULT_UNLOCKED: Array[int] = [135, 167, 182]

# animation
const CHARACTER_ANIMATION_PATH: String = "res://entities/character_animations/sora.tres"

# basic attack, ultimate
const CHARACTER_BASIC_ATTACK_PATH: String = "res://abilities/attack/sora_slash.tscn"
const CHARACTER_ULTIMATE_PATH: String = "res://abilities/attack/sora_slash.tscn"

#endregion

# ..............................................................................
