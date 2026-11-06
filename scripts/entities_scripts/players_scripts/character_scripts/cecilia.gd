extends PlayerStats

# CECILIA (CHARACTER)

# Score: 4.21 + 15% Crit Damage
# Black Magic - Debuff

# ..............................................................................

#region CONSTANTS

# name, index
const CHARACTER_NAME: String = "Cecilia Immergreen"
const CHARACTER_INDEX: int = 2

# health, mana, stamina
const CHARACTER_HEALTH: float = 362.0 # +162 (+0.81 T1)
const CHARACTER_MANA: float = 28.0 # +18 (+1.8 T1)
const CHARACTER_STAMINA: float = 999.0

# basic stats
const CHARACTER_DEFENSE: float = 8.0 # -2 (-0.2 T1)
const CHARACTER_WARD: float = 16.0 # +6 (+1.2 T1)
const CHARACTER_STRENGTH: float = 5.0 # -5 (-1 T1)
const CHARACTER_INTELLIGENCE: float = 18.0 # +8 (+1.6 T1)
const CHARACTER_SPEED: float = 0.0
const CHARACTER_AGILITY: float = 0.0
const CHARACTER_CRIT_CHANCE: float = 0.05
const CHARACTER_CRIT_DAMAGE: float = 1.65 # +0.15 Crit Damage

# nexus
const CHARACTER_DEFAULT_UNLOCKED: Array[int] = [284, 333, 364]

# animation
const CHARACTER_ANIMATION_PATH: String = \
	"res://resources/entities_resources/characters_resources/cecilia.tres"

# basic attack, ultimate
const CHARACTER_BASIC_ATTACK_PATH: String = "res://abilities/attack/sora_slash.tscn"
const CHARACTER_ULTIMATE_PATH: String = "res://abilities/attack/sora_slash.tscn"

#endregion

# ..............................................................................

#region ANIMATION CONSTANTS

const ACCESSORY_ANIMATION_COOLDOWN: float = 14.0

#endregion

# ..............................................................................

#region VARIABLES

var key_wind_spin_count: int = randi_range(1, 3)

#endregion

# ..............................................................................

#region FUNCTIONS

func update_animation_offsets() -> void:
	var eyes_animation_node: AnimatedSprite2D = base.get_node(^"Animation/EyesAnimation")
	var accessory_animation_node: AnimatedSprite2D = base.get_node(^"Animation/AccessoryAnimation")

	match base.get_node(^"Animation").frame:
		0:
			eyes_animation_node.offset.y = -9.0
			eyes_animation_node.stop()

			if accessory_animation_node.is_playing():
				key_wind_spin_count -= 1

				if key_wind_spin_count == 0:
					key_wind_spin_count = randi_range(1, 3)
					accessory_animation_node.stop()

			accessory_animation_node.offset.y = -22.0
		1:
			eyes_animation_node.offset.y = -8.0
			accessory_animation_node.offset.y = -21.0
		_:
			eyes_animation_node.offset.y = -7.0
			accessory_animation_node.offset.y = -20.0

#endregion

# ..............................................................................
