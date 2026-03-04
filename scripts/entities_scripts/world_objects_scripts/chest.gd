extends AnimatedSprite2D

func can_interact() -> bool:
	return TextBox.is_inactive() and Combat.not_in_combat()

func interact() -> void:
	frame = 1
