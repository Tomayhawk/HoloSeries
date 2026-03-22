extends AnimatedSprite2D
# ..............................................................................

#region CONSTANTS

const DIALOGUE_PATH: String = "res://dialogues/kobo.json"

#endregion

# ..............................................................................

#region DIALOGUE

func attempt_interact() -> void:
	if Combat.not_in_combat():
		initiate_dialogue()


func initiate_dialogue() -> void:
	Global.open_text_box(self, DIALOGUE_PATH)

#endregion

# ..............................................................................
