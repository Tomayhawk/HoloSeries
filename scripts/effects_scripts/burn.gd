extends Effect

# BURN
# deals physical damage periodically

# ..............................................................................

#region VARIABLES

var damage_types: int = (
		Damage.DamageTypes.PLAYER_HIT
		| Damage.DamageTypes.PHYSICAL
		| Damage.DamageTypes.NO_CRITICAL
		| Damage.DamageTypes.NO_MISS
)

var burn_interval: float = 1.5
var burn_damage: float = 4.0
var burn_increment: float = -2.0
var burn_count: int = 8

#endregion

# ..............................................................................

#region FUNCTIONS

func _init() -> void:
	effect_type = Entities.Status.BURN
	effect_timer = burn_interval


func effect_timeout(stats: EntityStats) -> void:
	# trigger burn
	Damage.combat_damage(burn_damage, damage_types, stats, stats)

	# increment burn damage
	burn_damage += burn_increment

	# decrement burn count
	burn_count -= 1

	if burn_count == 0:
		remove_effect(stats)
	else:
		effect_timer = burn_interval

#endregion

# ..............................................................................
