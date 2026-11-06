extends NinePatchRect

# ..............................................................................

#region CONSTANTS

const BLOCK_TYPE: int = 0

#endregion

# ..............................................................................

#region VARIABLES

var cursor_offset: Vector2 = Vector2.ZERO

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
		dragging.snap_block(%OperatorMarginContainer)
	elif dragging.BLOCK_TYPE in [0, 2] and mouse_on_block(%ContentVBoxContainer):
		accept_event()
		dragging.snap_block(%ContentVBoxContainer)


func _gui_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"action") or not mouse_on_block(self):
		return

	accept_event()

	if get_parent() != manager_ui_node:
		unsnap_block()
	else:
		manager_ui_node.move_child(self, -1)

	# drag block
	cursor_offset = position - get_global_mouse_position()
	manager_ui_node.dragging_block = self
	set_process(true)

#endregion

# ..............................................................................

#region FUNCTIONS

func mouse_on_block(block_node: Control) -> bool:
	return Rect2(block_node.global_position, block_node.size
			).has_point(get_global_mouse_position())


func snap_block(new_parent: Control) -> void:
	texture.region.position.y = 64.0
	texture.region.size.y = 56.0

	reparent(new_parent)


func unsnap_block() -> void:
	get_parent().get_parent().custom_minimum_size = Vector2.ZERO
	get_parent().get_parent().reset_size.call_deferred()
	reparent(manager_ui_node)
	manager_ui_node.dragging_block = self
	cursor_offset = position - get_global_mouse_position()

	texture.region.position.y = 0.0
	texture.region.size.y = 58.0

	set_process(true)

#endregion

# ..............................................................................

#region SIGNALS

func _on_content_margin_container_resized() -> void:
	%ContentMarginContainer.custom_minimum_size = %ContentMarginContainer.size
	custom_minimum_size = %ContentMarginContainer.custom_minimum_size.max(
			%OperatorMarginContainer.custom_minimum_size)


func _on_operator_margin_container_resized() -> void:
	%OperatorMarginContainer.custom_minimum_size = %OperatorMarginContainer.size
	custom_minimum_size = %ContentMarginContainer.custom_minimum_size.max(
			%OperatorMarginContainer.custom_minimum_size)
	%ContentMarginContainer.size = custom_minimum_size

#endregion

# ..............................................................................
