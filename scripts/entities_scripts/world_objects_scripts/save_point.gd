extends AnimatedSprite2D

# SAVE POINT (WORLD OBJECT)

# ..............................................................................

#region FUNCTIONS

func can_interact() -> bool:
	return Combat.not_in_combat()


func interact() -> void:
	Global.global_ui(Global.Ui.NONE, Global.Ui.SAVE_POINT)

#endregion

# ..............................................................................
