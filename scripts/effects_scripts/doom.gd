extends Effect

# DOOM
# kills target instantly on effect timeout

# ..............................................................................

#region INITIAL

func _init() -> void:
	effect_type = Entities.Status.DOOM
	effect_timer = 30.0

#endregion

# ..............................................................................

#region FUNCTIONS

func effect_timeout(stats: EntityStats) -> void:
	stats.update_health(-999999.0)
	remove_effect(stats)


#endregion

# ..............................................................................
