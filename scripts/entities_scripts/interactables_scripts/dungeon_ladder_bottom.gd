extends Sprite2D

# DUNGEON LADDER BOTTOM (INTERACTABLE)

# ..............................................................................

#region FUNCTIONS

func toggle_highlight() -> void:
	texture.region.position.x = 32.0 if texture.region.position.x == 0.0 else 0.0


func attempt_interact() -> void:
	if Combat.not_in_combat():
		texture.region.position.x = 32.0 if texture.region.position.x == 0.0 else 0.0

#endregion

# ..............................................................................
