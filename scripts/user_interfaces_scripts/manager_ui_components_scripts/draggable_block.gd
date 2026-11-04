extends Control

var cursor_offset: Vector2 = Vector2.ZERO
var dragging: bool = false

func _process(_delta: float) -> void:
	if dragging:
		position = get_global_mouse_position() + cursor_offset


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"action"):
		var global_rect = Rect2(position, $VBoxContainer.size)
		if global_rect.has_point(event.position):
			cursor_offset = position - get_global_mouse_position()
			dragging = true
	elif event.is_action_released(&"action"):
		dragging = false
