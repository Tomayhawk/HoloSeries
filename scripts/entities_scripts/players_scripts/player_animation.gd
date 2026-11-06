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
	},
}

const DIRECTION_TO_STRING: Dictionary[Direction, String] = {
	Direction.RIGHT: &"right",
	Direction.DOWN: &"down",
	Direction.LEFT: &"left",
	Direction.UP: &"up",
}

const DASH_ANIMATION_MULTIPLIER: float = 2.0

#endregion

# ..............................................................................

#region VARIABLES

var animation_type: Type = Type.IDLE
var animation_direction: Direction = Direction.DOWN

@onready var base: PlayerBase = get_parent()

#endregion

# ..............................................................................

#region FUNCTIONS

func update_animation() -> void:
	if not base.stats.alive:
		return

	var last_animation_type: Type = animation_type
	set_animation_type()

	# GUARD: from action to action -> no animation change
	if animation_type == last_animation_type and base.in_action():
		return

	set_animation_direction()
	set_animation_speed()

	# toggle eyes and accessory animations for idle animation
	$EyesAnimation.visible = animation_type == Type.IDLE
	$AccessoryAnimation.visible = animation_type == Type.IDLE

	# update eyes and accessory animation directions
	$EyesAnimation.animation = DIRECTION_TO_STRING[animation_direction]
	$AccessoryAnimation.animation = DIRECTION_TO_STRING[animation_direction]

	play(ANIMATION_DICT[animation_type][animation_direction])


func set_animation_type() -> void:
	animation_type = Type.IDLE

	if base.in_action():
		if base.action_type == base.ActionType.MELEE:
			animation_type = Type.MELEE
	elif base.in_motion():
		animation_type = Type.WALK


func set_animation_direction() -> void:
	var target_direction: Vector2

	if base.action_direction == Vector2.ZERO:
		target_direction = base.velocity
	else:
		target_direction = base.action_direction

	if target_direction == Vector2.ZERO:
		return

	var temp_x: float = target_direction.x
	var temp_y: float = target_direction.y

	if absf(temp_y) > absf(temp_x):
		animation_direction = Direction.DOWN if temp_y > 0 else Direction.UP
	else:
		animation_direction = Direction.RIGHT if temp_x > 0 else Direction.LEFT


func set_animation_speed() -> void:
	if animation_type != Type.WALK:
		speed_scale = 1.0
		return

	speed_scale = base.stats.move_speed / base.stats.MOVE_SPEED_BASE

	if base.move_state == base.MoveState.DASH:
		speed_scale *= DASH_ANIMATION_MULTIPLIER
	elif base.move_state == base.MoveState.SPRINT:
		speed_scale *= base.stats.sprint_multiplier

#endregion

# ..............................................................................

#region SIGNALS

func _on_eyes_animation_cooldown_timeout() -> void:
	$EyesAnimation.play()
	$EyesAnimationCooldown.wait_time = randf_range(12.0, 18.0)


func _on_accessory_animation_cooldown_timeout() -> void:
	$AccessoryAnimation.play()
	$AccessoryAnimationCooldown.wait_time = \
			base.stats.ACCESSORY_ANIMATION_COOLDOWN * randf_range(1.0, 1.5)

#endregion

# ..............................................................................
