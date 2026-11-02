extends CanvasLayer

# TEXT BOX UI (GLOBAL UI)

# ..............................................................................

#region CONSTANTS

enum DialogueState {
	TYPING,
	END,
	WAITING,
}

const OPTION_BUTTON_PRELOAD: PackedScene = \
		preload("res://user_interfaces/dialogue_ui_components/option_button.tscn")

const TYPING_DURATION_MULTIPLIER: float = 0.04

#endregion

# ..............................................................................

#region VARIABLES

var dialogue_state: DialogueState = DialogueState.TYPING

var npc_node: AnimatedSprite2D = null

var dialogue_tree: DialogueTree = null
var dialogue_index: int = 0
var current_node: DialogueNode = null
var dialogue_text: Array[String] = []

var tween: Tween = null

@onready var dialogue_box: MarginContainer = %DialogueMargin
@onready var text_label: Label = %TextAreaLabel
@onready var end_label: Label = %TextEndLabel

#endregion

# ..............................................................................

#region INITIAL

func _ready() -> void:
	clear_text()

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# INPUT: continue, action -> handle text box input
	if event.is_action(&"continue") or event.is_action(&"action"):
		if dialogue_state != DialogueState.WAITING:
			Inputs.accept_event()
			if event.is_pressed() and not event.is_echo():
				dialogue_input()

#endregion

# ..............................................................................

#region INPUT FUNCTIONS

func dialogue_input() -> void:
	# force end dialogue text
	if dialogue_state == DialogueState.TYPING:
		force_end_text()
	# continue to next dialogue text
	elif dialogue_state == DialogueState.END:
		continue_dialogue()

#endregion

# ..............................................................................

#region DIALOGUE LOOP

func npc_dialogue(npc: AnimatedSprite2D, tree: DialogueTree) -> void:
	npc_node = npc
	dialogue_tree = tree
	dialogue_index = 0
	current_node = tree.nodes[dialogue_index]
	dialogue_text.assign(current_node.text)

	# toggle world states and show text box
	Global.pause_movement()
	dialogue_box.show()

	# start dialogue
	start_text()


func start_text() -> void:
	dialogue_state = DialogueState.TYPING

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
	text_label.visible_ratio = 1.0

	end_text()


func end_text() -> void:
	dialogue_state = DialogueState.END
	end_label.show()

	# handle options and actions
	if dialogue_text.is_empty() and not current_node.options.is_empty():
		request_response()


func continue_dialogue() -> void:
	if dialogue_text.is_empty() and current_node.action != &"":
		# handle action
		if current_node.action != &"end_dialogue":
			npc_node.call(current_node.action)

		end_dialogue()
	else:
		start_text()


func end_dialogue() -> void:
	clear_text()

	Global.global_ui(Global.Ui.DIALOGUE, Global.Ui.NONE)
	Global.resume_movement()


func request_response() -> void:
	dialogue_state = DialogueState.WAITING
	end_label.hide()

	for i in current_node.options.size():
		var option_button: Button = OPTION_BUTTON_PRELOAD.instantiate()
		option_button.text = current_node.options[i].text
		option_button.pressed.connect(_on_option_button_pressed.bind(i))
		%OptionsMargin/VBoxContainer.add_child(option_button)

#endregion

# ..............................................................................

#region UTILITIES

func clear_text() -> void:
	dialogue_box.hide()
	text_label.text = ""
	end_label.hide()

#endregion

# ..............................................................................

#region SIGNALS

func _on_option_button_pressed(extra_arg_0: int) -> void:
	dialogue_index = current_node.options[extra_arg_0].branch
	current_node = dialogue_tree.nodes[dialogue_index]
	dialogue_text.assign(current_node.text)

	# clear options
	for option_button in %OptionsMargin/VBoxContainer.get_children().duplicate():
		option_button.queue_free()

	continue_dialogue()

#endregion

# ..............................................................................
