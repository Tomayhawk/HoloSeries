extends AnimatedSprite2D

# SAVE POINT (INTERACTABLE)

# ..............................................................................

#region FUNCTIONS

func attempt_interact() -> void:
	if Combat.not_in_combat():
		Global.global_ui(Global.Ui.NONE, Global.Ui.SAVE_POINT)

#endregion

# ..............................................................................
