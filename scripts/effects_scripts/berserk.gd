extends Effect

# BERSERK (EFFECT)
# DESCRIPTION

# ..............................................................................

#region INITIAL

func _init() -> void:
    effect_name = "Berserk"
    effect_type = Entities.Status.BERSERK

#endregion

# ..............................................................................

# TODO: cannot be controlled as the main player
# TODO: can only use basic attack, and cannot use any items, abilities or ultimates
