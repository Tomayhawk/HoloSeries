extends AnimatedSprite2D
# ..............................................................................

#region CONSTANTS

const DIALOGUE_PATH: String = "res://dialogues/kobo.tres"

#endregion

# ..............................................................................

#region VARIABLES

var npc_state: int = Global.world_states[0]

#endregion

# ..............................................................................

#region DIALOGUE

func toggle_highlight() -> void:
	pass


func attempt_interact() -> void:
	if Combat.not_in_combat():
		initiate_dialogue()


func initiate_dialogue() -> void:
	Global.start_dialogue(self, load(DIALOGUE_PATH))

#endregion

# ..............................................................................
