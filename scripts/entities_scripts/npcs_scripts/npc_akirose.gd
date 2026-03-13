extends AnimatedSprite2D

# ..............................................................................

#region CONSTANTS

const DIALOGUE_PATH: String = "res://dialogues/akirose.json"
const AKIROSE_PATH: String = "res://scripts/entities_scripts/players_scripts/character_scripts/akirose.gd"

#endregion

# ..............................................................................

#region DIALOGUE

func initiate_dialogue() -> void:
	TextBox.npc_dialogue(self, DIALOGUE_PATH)

#endregion

# ..............................................................................

#region RECRUIT

func recruit_character() -> void:
	Players.recruit_character(load(AKIROSE_PATH).new())
	queue_free()

#endregion

# ..............................................................................
