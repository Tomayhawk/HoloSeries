extends Effect

# INVINCIBLE
# grants temporary invincibility frames

# ..............................................................................

#region FUNCTIONS

func _init() -> void:
	effect_type = Entities.Status.INVINCIBLE
	effect_timer = 0.1

#endregion

# ..............................................................................
