extends AnimatedSprite2D

# CHEST (INTERACTABLE)

# ..............................................................................

#region FUNCTIONS

func toggle_highlight() -> void:
	pass


func attempt_interact() -> void:
	if Combat.not_in_combat():
		speed_scale = 1.0 if frame == 0 else -1.0
		play()

#endregion

# ..............................................................................
