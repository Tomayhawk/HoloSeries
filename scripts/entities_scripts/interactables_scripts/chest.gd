extends AnimatedSprite2D

# CHEST (INTERACTABLE)

# ..............................................................................

#region FUNCTIONS

func attempt_interact() -> void:
	if Combat.not_in_combat():
		frame = 1

#endregion

# ..............................................................................
