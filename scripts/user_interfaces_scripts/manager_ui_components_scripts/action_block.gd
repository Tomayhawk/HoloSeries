extends NinePatchRect

# ..............................................................................

#region CONSTANTS

const BLOCK_TYPE: int = 2

#endregion

# ..............................................................................

#region VARIABLES

var cursor_offset: Vector2 = Vector2.ZERO

@onready var manager_ui_node: CanvasLayer = \
		Global.get_node(Global.GLOBAL_UI[Global.Ui.MANAGER][Global.UiKeys.NAME])

#endregion

# ..............................................................................

#region PROCESS

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
	if event.is_action_released(&"action") and manager_ui_node.dragging_block == self:
		manager_ui_node.set_deferred(&"dragging_block", null)
		set_process(false)


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
	texture.region.position.y = 32.0
	texture.region.size.y = 30.0

	reparent(new_parent)


func unsnap_block() -> void:
	get_parent().get_parent().reset_size.call_deferred()
	reparent(manager_ui_node)
	manager_ui_node.dragging_block = self
	cursor_offset = position - get_global_mouse_position()

	texture.region.position.y = 0.0
	texture.region.size.y = 32.0

	set_process(true)


#endregion

# ..............................................................................
