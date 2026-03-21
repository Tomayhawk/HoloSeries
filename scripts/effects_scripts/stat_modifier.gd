extends Effect

# STAT MODIFIER (EFFECT)
# modifies a specific stat temporarily

# ..............................................................................

#region VARIABLES

var stat_name: StringName = &"strength"
var stat_change: float = 1.0

#endregion

# ..............................................................................

#region INITIAL

func _init() -> void:
	effect_name = "Stat Modifier"
	effect_type = Entities.Status.STAT_MODIFIER

#endregion

# ..............................................................................

#region FUNCTIONS

func set_stat_effect(stats: EntityStats) -> void:
	stats.set(stat_name, stats.get(stat_name) + stat_change)


func effect_timeout(stats: EntityStats) -> void:
	stats.set(stat_name, stats.get(stat_name) - stat_change)
	remove_effect(stats)

#endregion

# ..............................................................................
