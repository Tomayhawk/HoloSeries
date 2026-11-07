extends NinePatchRect

# ..............................................................................

#region CONSTANTS

const BLOCK_TYPE: int = 0

#endregion

# ..............................................................................

#region VARIABLES

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
	elif dragging.BLOCK_TYPE == 1 and mouse_on_block(%OperatorMarginContainer):
		accept_event()
		dragging.snap_block(self)
	elif dragging.BLOCK_TYPE in [0, 2] and mouse_on_block(%ContentVBoxContainer):
		accept_event()
		dragging.snap_block(self)


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
	texture.region.position.y = 64.0
	reparent(parent_block.get_node(^"%ContentVBoxContainer"))


func unsnap_block() -> void:
	reparent(manager_ui_node)
	texture.region.position.y = 0.0

	parent_block.get_node(^"%ContentVBoxContainer").reset_size()
	parent_block = null

	get_node(^"%ContentVBoxContainer").reset_size()

#endregion

# ..............................................................................

#region SIGNALS

func _on_resized() -> void:
	if parent_block and get_parent().size.x > size.x:
		size.x = get_parent().size.x

	$MarginContainer.size = size


func _on_child_container_resized() -> void:
	$MarginContainer.reset_size()

	custom_minimum_size = $MarginContainer.size
	size = $MarginContainer.size

	if parent_block:
		parent_block.get_node(^"%ContentVBoxContainer").reset_size()

		# handle situations where the minimum size is larger than the local minimum
		$MarginContainer.size = size

#endregion

# ..............................................................................
