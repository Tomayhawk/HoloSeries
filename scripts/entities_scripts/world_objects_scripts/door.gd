extends AnimatedSprite2D

# DOOR (WORLD OBJECT)

# ..............................................................................

#region FUNCTIONS

func can_interact() -> bool:
	return Combat.not_in_combat()

#endregion

# ..............................................................................
