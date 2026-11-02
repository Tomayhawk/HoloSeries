extends AnimatedSprite2D

# ..............................................................................

#region CONSTANTS

const DIALOGUE_PATH: String = "res://dialogues/akirose.tres"
const AKIROSE_PATH: String = "res://scripts/entities_scripts/players_scripts/character_scripts/akirose.gd"

#endregion

# ..............................................................................

#region VARIABLES

var npc_state: int = Global.world_states[1]

#endregion

# ..............................................................................

#region READY

func _ready() -> void:
	if npc_state == -1:
		queue_free()

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

#region RECRUIT

func recruit_character() -> void:
	await Players.camera.toggle_black_screen(true)

	Players.recruit_character(load(AKIROSE_PATH).new())
	queue_free()

	Players.camera.toggle_black_screen(false)

	Global.world_states[1] = -1

#endregion

# ..............................................................................
