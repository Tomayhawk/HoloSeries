extends AnimatedSprite2D
# ..............................................................................

#region CONSTANTS

const DIALOGUE_PATH: String = "res://dialogues/kobo.json"

#endregion

# ..............................................................................

#region DIALOGUE

func initiate_dialogue() -> void:
	TextBox.npc_dialogue(self, DIALOGUE_PATH)

func end_dialogue() -> void:
	pass

#endregion

# ..............................................................................
