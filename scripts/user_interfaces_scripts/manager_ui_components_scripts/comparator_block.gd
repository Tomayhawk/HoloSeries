extends TextureRect

# ..............................................................................

#region VARIABLES

var block_type: Manager.BlockType = Manager.BlockType.EQUALS

var cursor_offset: Vector2 = Vector2.ZERO

var parent_block: Control = null

@onready var manager_ui_node: CanvasLayer = \
		Global.get_node(Global.GLOBAL_UI[Global.Ui.MANAGER][Global.UiKeys.NAME])

#endregion

# ..............................................................................

#region READY

func _ready() -> void:
	set_process(false)

#endregion

# ..............................................................................

#region PROCESS

func _process(_delta: float) -> void:
	position = get_global_mouse_position() + cursor_offset

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	var dragging: Control = manager_ui_node.dragging_block

	if not event.is_action_released(&"action") or not is_instance_valid(dragging):
		return

	if dragging == self:
		manager_ui_node.set_deferred(&"dragging_block", null)
		set_process(false)
	else:
		pass # TODO: handle comparator inputs


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

#endregion

# ..............................................................................

#region FUNCTIONS

func mouse_on_block(block_node: Control) -> bool:
	return Rect2(block_node.global_position, block_node.size
			).has_point(get_global_mouse_position())


func snap_block(new_parent_block: Control) -> void:
	parent_block = new_parent_block
	texture.region.position.y = 32.0
	reparent(parent_block.get_node(^"%OperatorMarginContainer"))


func unsnap_block() -> void:
	reparent(manager_ui_node)

	texture.region.position.y = 0.0

	parent_block.get_node(^"%OperatorMarginContainer").reset_size()
	parent_block = null

	reset_size()

#endregion

# ..............................................................................
