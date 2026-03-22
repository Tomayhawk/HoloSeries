extends CanvasLayer

# TEXT BOX UI (GLOBAL UI)

# TODO: use .tres instead of .JSON/.dat
# TODO: should use saved states instead

# ..............................................................................

#region CONSTANTS

enum TextBoxState {
	TYPING,
	END,
	WAITING,
}

const NPC_STATES_PATH: String = "res://dialogues/npc_default_states.json"
const TYPING_DURATION_MULTIPLIER: float = 0.04

#endregion

# ..............................................................................

#region VARIABLES

var text_box_state: TextBoxState = TextBoxState.TYPING

var npcs_states: Dictionary = {}
var npc_node: AnimatedSprite2D = null

var dialogue: Dictionary = {}
var dialogue_key: String = ""
var dialogue_text: Array = []

var tween: Tween = null

@onready var text_box: MarginContainer = %TextBoxMargin
@onready var text_label: Label = %TextAreaLabel
@onready var end_label: Label = %TextEndLabel

@onready var option_buttons: Array[Button] = [
	%Option1Button, %Option2Button, %Option3Button, %Option4Button
]

#endregion

# ..............................................................................

#region INITIAL

func _ready() -> void:
	initialize_npc_states()

	# empty text boxes
	clear_text_box()
	clear_options()

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# INPUT: continue, action -> handle text box input
	if event.is_action(&"continue") or event.is_action(&"action"):
		if text_box_state != TextBoxState.WAITING:
			Inputs.accept_event()
		if event.is_pressed() and not event.is_echo():
			text_box_input()

#endregion

# ..............................................................................

#region INPUT FUNCTIONS

func text_box_input() -> void:
	# force end dialogue text
	if text_box_state == TextBoxState.TYPING:
		force_end_text()
	# continue to next dialogue text
	elif text_box_state == TextBoxState.END:
		continue_dialogue()

#endregion

# ..............................................................................

#region DIALOGUE LOOP

func npc_dialogue(npc: AnimatedSprite2D, file_path: String) -> void:
	# set npc dialogue_branch
	npc_node = npc

	# set dialogue
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	dialogue = JSON.parse_string(json_string)

	# toggle world states and show text box
	Global.pause_movement()
	text_box.show()

	# set dialogue key and texts
	dialogue_key = npcs_states[file_path.get_file().get_basename()]
	dialogue_text = dialogue[dialogue_key]["text"]

	# start dialogue
	start_text()


func start_text() -> void:
	text_box_state = TextBoxState.TYPING

	# set text and ui
	text_label.text = dialogue_text.pop_front()
	text_label.visible_characters = 0
	end_label.hide()

	# animate typing
	tween = create_tween()
	tween.tween_property(
			text_label,
			"visible_ratio",
			1.0,
			len(text_label.text) * TYPING_DURATION_MULTIPLIER
	)
	tween.finished.connect(end_text)


func force_end_text() -> void:
	# force end text animation
	tween.kill()
	text_label.set_visible_ratio(1.0)

	end_text()


func end_text() -> void:
	text_box_state = TextBoxState.END
	end_label.show()

	# handle options and actions
	if dialogue_text.is_empty() and dialogue[dialogue_key].has("options"):
		request_response()


func continue_dialogue() -> void:
	if dialogue_text.is_empty() and dialogue[dialogue_key].has("action"):
		# handle action
		var action_name: StringName = StringName(dialogue[dialogue_key]["action"])

		if action_name != StringName("end_dialogue"):
			npc_node.call(action_name)

		end_dialogue()
	else:
		start_text()


func end_dialogue() -> void:
	clear_text_box()

	Global.global_ui(Global.Ui.TEXT_BOX, Global.Ui.NONE)
	Global.resume_movement()


func request_response() -> void:
	text_box_state = TextBoxState.WAITING
	end_label.hide()

	# set option buttons
	var dialogue_options: Array = dialogue[dialogue_key]["options"]

	for optionIndex in dialogue_options.size():
		option_buttons[optionIndex].text = dialogue_options[optionIndex]
		option_buttons[optionIndex].show()

#endregion

# ..............................................................................

#region UTILITIES

func initialize_npc_states() -> void:
	var file = FileAccess.open(NPC_STATES_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	npcs_states = JSON.parse_string(json_string)


func set_npc_states(_key: String, _state: String) -> void:
	pass


func clear_text_box() -> void:
	text_box.hide()
	text_label.text = ""
	end_label.hide()


func clear_options() -> void:
	for option_button in option_buttons:
		option_button.text = ""
		option_button.hide()

#endregion

# ..............................................................................

#region SIGNALS

func _on_option_button_pressed(extra_arg_0: int) -> void:
	dialogue_key = dialogue[dialogue_key]["branches"][extra_arg_0]
	dialogue_text = dialogue[dialogue_key]["text"]

	clear_options()
	continue_dialogue()

#endregion

# ..............................................................................
