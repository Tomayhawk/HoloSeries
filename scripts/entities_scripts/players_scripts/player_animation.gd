extends AnimatedSprite2D

# PLAYER ANIMATION

# ..............................................................................

#region CONSTANTS

enum Type {
	IDLE,
	WALK,
	MELEE,
}

enum Direction {
	RIGHT,
	DOWN,
	LEFT,
	UP,
}

const ANIMATION_DICT: Dictionary[Type, Dictionary] = {
	Type.IDLE: {
		Direction.RIGHT: &"right_idle",
		Direction.DOWN: &"down_idle",
		Direction.LEFT: &"left_idle",
		Direction.UP: &"up_idle",
	},
	Type.WALK: {
		Direction.RIGHT: &"right_walk",
		Direction.DOWN: &"down_walk",
		Direction.LEFT: &"left_walk",
		Direction.UP: &"up_walk",
	},
	Type.MELEE: {
		Direction.RIGHT: &"right_attack",
		Direction.DOWN: &"down_attack",
		Direction.LEFT: &"left_attack",
		Direction.UP: &"up_attack",
	}
}

#endregion

# ..............................................................................

#region VARIABLES

var animation_direction: Direction = Direction.DOWN

@onready var base: PlayerBase = get_parent()

#endregion

# ..............................................................................

#region FUNCTIONS

func update_animation() -> void:
	if not base.stats.alive or (base.in_forced_move_state() and not base.in_action()):
		return

	var next_animation: StringName = animation
	var animation_speed: float = 1.0

	# determine next animation based on action and move states
	if base.in_action():
		# melee
		if base.action_type == base.ActionType.MELEE:
			next_animation = [
				&"right_attack",
				&"down_attack",
				&"left_attack",
				&"up_attack",
			][(roundi(base.action_direction.angle() / (PI / 2)) + 4) % 4]
	elif base.move_state == base.MoveState.IDLE:
		# idle
		next_animation = [
			&"up_idle",
			&"down_idle",
			&"left_idle",
			&"right_idle"
		][base.move_direction if base.move_direction < 4 else base.move_direction % 2 + 2]
	else:
		# move
		next_animation = [
			&"up_walk",
			&"down_walk",
			&"left_walk",
			&"right_walk"
		][base.move_direction if base.move_direction < 4 else base.move_direction % 2 + 2]

		# update animation speed based on movement speed
		animation_speed = base.stats.move_speed / 70.0
		if base.move_state == base.MoveState.DASH:
			animation_speed *= 2.0
		elif base.move_state == base.MoveState.SPRINT:
			animation_speed *= base.stats.sprint_multiplier

	# play animation if changed
	if next_animation != animation:
		play(next_animation)
		frame_changed.emit()
		animation_finished.emit()

	# update animation speed
	speed_scale = animation_speed


# TODO: not implemented yet
func set_animation_direction(temp_direction: Vector2 = Vector2.ZERO) -> void:
	if temp_direction == Vector2.ZERO:
		return

	var temp_x: float = temp_direction.x
	var temp_y: float = temp_direction.y

	if absf(temp_y) > absf(temp_x):
		animation_direction = Direction.DOWN if temp_y > 0 else Direction.UP
	else:
		animation_direction = Direction.RIGHT if temp_x > 0 else Direction.LEFT

#endregion

# ..............................................................................
