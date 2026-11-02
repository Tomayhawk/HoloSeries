extends Effect

# CONFUSE (EFFECT)
# DESCRIPTION

# ..............................................................................

#region INITIAL

func _init() -> void:
	effect_name = "Confuse"

#endregion

# ..............................................................................

# cannot become main player
# can only use basic attack, and cannot use any items, abilities or ultimates
# attacks ally instead
