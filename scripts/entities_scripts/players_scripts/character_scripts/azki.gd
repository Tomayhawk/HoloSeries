extends PlayerStats

# AZKI (CHARACTER)

# Score: 4.265 + 5% Crit Rate
# Buffer - Skills

# ..............................................................................

#region CONSTANTS

# name, index
const CHARACTER_NAME: String = "AZKi"
const CHARACTER_INDEX: int = 1

# health, mana, stamina
const CHARACTER_HEALTH: float = 373.0 # +173 (+0.865 T1)
const CHARACTER_MANA: float = 40.0 # +30 (+3 T1)
const CHARACTER_STAMINA: float = 100.0

# basic stats
const CHARACTER_DEFENSE: float = 8.0 # -2 (-0.2 T1)
const CHARACTER_WARD: float = 6.0 # -4 (-0.8 T1)
const CHARACTER_STRENGTH: float = 9.0 # -1 (-0.2 T1)
const CHARACTER_INTELLIGENCE: float = 12.0 # +2 (+0.4 T1)
const CHARACTER_SPEED: float = 2.0 # +2 (+2 T1)
const CHARACTER_AGILITY: float = 2.0 # +2 (+2 T1)
const CHARACTER_CRIT_CHANCE: float = 0.10 # +0.05 Crit Rate
const CHARACTER_CRIT_DAMAGE: float = 1.50

# nexus
const CHARACTER_DEFAULT_UNLOCKED: Array[int] = [139, 154, 170]

# animation
const CHARACTER_ANIMATION_PATH: String = "res://entities/character_animations/azki.tres"

# basic attack, ultimate
const CHARACTER_BASIC_ATTACK_PATH: String = "res://abilities/attack/sora_slash.tscn"
const CHARACTER_ULTIMATE_PATH: String = "res://abilities/attack/sora_slash.tscn"

#endregion

# ..............................................................................
