extends AnimatedSprite2D

# SAVE POINT (WORLD OBJECT)

# ..............................................................................

#region FUNCTIONS

func can_interact() -> bool:
	return Combat.not_in_combat()

func interact() -> void:
	pass # TODO: Display Save UI

#endregion

# ..............................................................................
