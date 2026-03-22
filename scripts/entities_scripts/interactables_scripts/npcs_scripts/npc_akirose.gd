extends AnimatedSprite2D

# ..............................................................................

#region CONSTANTS

const DIALOGUE_PATH: String = "res://dialogues/akirose.json"
const AKIROSE_PATH: String = "res://scripts/entities_scripts/players_scripts/character_scripts/akirose.gd"

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

#region RECRUIT

func recruit_character() -> void:
	await Players.camera.toggle_black_screen(true)

	Players.recruit_character(load(AKIROSE_PATH).new())
	queue_free()

	Players.camera.toggle_black_screen(false)

#endregion

# ..............................................................................
