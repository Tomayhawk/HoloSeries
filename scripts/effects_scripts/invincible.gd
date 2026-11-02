extends Effect

# INVINCIBLE (EFFECT)
# grants temporary invincibility frames

# ..............................................................................

#region INITIAL

func _init() -> void:
	effect_name = "Invincible"
	effect_type = Entities.Status.INVINCIBLE
	effect_timer = 0.1

#endregion

# ..............................................................................
