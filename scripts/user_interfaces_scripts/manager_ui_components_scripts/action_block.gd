extends NinePatchRect

# ..............................................................................

#region VARIABLES

var block_type: Manager.BlockType = Manager.BlockType.ATTACK

var cursor_offset: Vector2 = Vector2.ZERO

var parent_block: Control = null

@onready var manager_ui_node: CanvasLayer = \
		Global.get_node(Global.GLOBAL_UI[Global.Ui.MANAGER][Global.UiKeys.NAME])

#endregion

# ..............................................................................

#region READY

func _ready() -> void:
	set_process(false)
	set_process_input(false)
	$MarginContainer.reset_size()

#endregion

# ..............................................................................

#region PROCESS

func _process(_delta: float) -> void:
	position = get_global_mouse_position() + cursor_offset

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	if event.is_action_released(&"action"):
		manager_ui_node.set_deferred(&"dragging_block", null)
		set_process(false)
		set_process_input(false)


func _gui_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"action"):
		return

	accept_event()

	# move block to the top of manager ui
	if parent_block:
		unsnap_block()
	else:
		manager_ui_node.move_child(self, -1)

	# drag block
	manager_ui_node.dragging_block = self
	cursor_offset = position - get_global_mouse_position()

	set_process(true)
	set_process_input(true)

#endregion

# ..............................................................................

#region FUNCTIONS

func snap_block(new_parent_block: Control) -> void:
	parent_block = new_parent_block
	texture.region.position.y = 32.0

	reparent(parent_block.get_node(^"%ContentVBoxContainer"))


func unsnap_block() -> void:
	reparent(manager_ui_node)

	texture.region.position.y = 0.0

	parent_block.get_node(^"%ContentVBoxContainer").reset_size()
	parent_block = null

	$MarginContainer.reset_size()

#endregion

# ..............................................................................

#region SIGNALS

func _on_resized() -> void:
	$MarginContainer.size = size
	if parent_block and get_parent().size.x > size.x:
		size.x = get_parent().size.x


func _on_margin_container_resized() -> void:
	custom_minimum_size = $MarginContainer.size
	reset_size()

	custom_minimum_size = $MarginContainer.get_combined_minimum_size()

#endregion

# ..............................................................................
