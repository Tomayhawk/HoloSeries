extends AnimatedSprite2D

# CHEST (WORLD OBJECT)

# ..............................................................................

#region FUNCTIONS

func can_interact() -> bool:
	return Combat.not_in_combat()

func interact() -> void:
	frame = 1

#endregion

# ..............................................................................
