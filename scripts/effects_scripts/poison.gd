extends Effect

# POISON
# deals damage periodically & cannot kill (leaves 1 HP)

# ..............................................................................

#region VARIABLES

var damage_types: int = (
		Damage.DamageTypes.PLAYER_HIT
		| Damage.DamageTypes.COMBAT
		| Damage.DamageTypes.MAGIC
		| Damage.DamageTypes.NO_CRITICAL
		| Damage.DamageTypes.NON_LETHAL
		| Damage.DamageTypes.NO_MISS
)

var origin_stats: EntityStats = null
var poison_interval: float = 3.0
var poison_damage: float = -8.0
var poison_count: int = 5
var min_rand: float = 0.95
var max_rand: float = 1.05

#endregion

# ..............................................................................

#region FUNCTIONS

func _init() -> void:
	effect_type = Entities.Status.POISON
	effect_timer = poison_interval


func effect_timeout(stats: EntityStats) -> void:
	# calculate and trigger poison
	var rand_poison_damage: float = poison_damage * randf_range(min_rand, max_rand)
	Damage.combat_damage(rand_poison_damage, damage_types, origin_stats, stats)

	# decrement poison count
	poison_count -= 1

	if poison_count == 0:
		remove_effect(stats)
	else:
		effect_timer = poison_interval

#endregion

# ..............................................................................
