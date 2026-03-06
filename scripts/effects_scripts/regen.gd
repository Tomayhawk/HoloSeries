extends Effect

# REGEN
# heals target periodically

# ..............................................................................

#region VARIABLES

var damage_types: int = (
		Damage.DamageTypes.PLAYER_HIT
		| Damage.DamageTypes.HEAL
		| Damage.DamageTypes.MAGIC
		| Damage.DamageTypes.NO_CRITICAL
		| Damage.DamageTypes.NO_MISS
)

var origin_stats: EntityStats = null
var regen_interval: float = 5.0
var regen_amount: float = 10.0
var regen_count: int = 7
var min_rand: float = 0.95
var max_rand: float = 1.05

#endregion

# ..............................................................................

#region FUNCTIONS

func _init() -> void:
	effect_type = Entities.Status.REGEN
	effect_timer = regen_interval


func effect_timeout(stats: EntityStats) -> void:
	# calculate and trigger regen
	var rand_regen_amount: float = regen_amount * randf_range(min_rand, max_rand)
	Damage.combat_damage(rand_regen_amount, damage_types, origin_stats, stats)

	# decrement regen count
	regen_count -= 1

	if regen_count == 0:
		remove_effect(stats)
	else:
		effect_timer = regen_interval

#endregion

# ..............................................................................
