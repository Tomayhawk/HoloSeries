class_name EntityBase
extends CharacterBody2D

# ENTITY BASE (ENTITY)

# ..............................................................................

#region SIGNALS

signal move_state_timeout
signal action_cooldown_timeout

#endregion

# ..............................................................................

#region CONSTANTS

enum MoveState {
	IDLE,
	WALK,
	DASH,
	SPRINT,
	KNOCKBACK,
	STUN,
}

enum ActionState {
	READY,
	WINDUP,
	EXECUTE,
	RECOVERY,
	COOLDOWN,
	DISABLED,
}

enum ActionType {
	MELEE,
	RANGED,
	MAGIC,
	SUMMON,
	ITEM,
	NONE,
}

const BASE_KNOCKBACK_TIME: float = 1.0

#endregion

# ..............................................................................

#region VARIABLES

var stats: EntityStats = null
var stats_process_interval: float = 0.0

# movement
var move_state: MoveState = MoveState.IDLE
var move_state_velocity: Vector2 = Vector2.ZERO
var move_state_duration: float = 0.5
var move_state_timer: float = 0.5

# action
var action_state: ActionState = ActionState.READY
var action_type: ActionType = ActionType.NONE
var action_node: Node = null
var action_direction: Vector2 = Vector2.ZERO
var action_cooldown: float = 0.0
var action_in_range: bool = false

# action targets
var action_target: EntityBase = null
var action_target_candidates: Array[EntityBase] = []
var action_target_types: int = 0
var action_target_stats: StringName = &""
var action_target_get_max: bool = true

#endregion

# ..............................................................................

#region PROCESS

func _process(delta: float) -> void:
	# decrease move state timer
	if move_state_timer > 0.0:
		move_state_timer -= delta
		if move_state_timer < 0.0:
			move_state_timeout.emit()

	# decrease action cooldown
	if action_cooldown > 0.0:
		action_cooldown -= delta
		if action_cooldown < 0.0:
			action_cooldown_timeout.emit()

	# process stats
	stats_process_interval += delta
	if stats_process_interval > 0.1:
		stats.stats_process(stats_process_interval)
		stats_process_interval = 0.0

#endregion

# ..............................................................................

#region KNOCKBACK & DEATH

func knockback(base_velocity: Vector2, base_duration: float = BASE_KNOCKBACK_TIME) -> void:
	move_state = MoveState.KNOCKBACK

	# set starting values
	var temp_multiplier: float = stats.knockback_multiplier()
	move_state_velocity = base_velocity * temp_multiplier
	move_state_duration = base_duration * minf(1.0, temp_multiplier)

	# set state variables
	velocity = move_state_velocity
	move_state_timer = move_state_duration


func death() -> void:
	process_mode = PROCESS_MODE_DISABLED

	# reset variables
	stats_process_interval = 0.0
	reset_movement()
	reset_action()
	reset_action_targets()

#endregion

# ..............................................................................

#region RESET VARIABLES

func reset_movement() -> void:
	move_state = MoveState.IDLE
	move_state_timer = 0.5
	move_state_duration = 0.5
	move_state_velocity = Vector2.DOWN


func reset_action() -> void:
	action_state = ActionState.READY
	action_type = ActionType.NONE
	action_cooldown = 0.0
	action_direction = Vector2.ZERO
	action_in_range = false


func reset_action_targets() -> void:
	action_target = null
	action_target_candidates.clear()
	action_target_types = 0
	action_target_stats = &""
	action_target_get_max = true

#endregion

# ..............................................................................

#region UTILITIES

func in_action() -> bool:
	return action_state in [ActionState.WINDUP, ActionState.EXECUTE, ActionState.RECOVERY]


func in_forced_move_state() -> bool:
	return move_state in [MoveState.KNOCKBACK, MoveState.STUN]

#endregion

# ..............................................................................

#region INTERACTION HIT BOX SIGNALS

func _on_interaction_hit_box_mouse_entered() -> void:
	if self in Entities.entities_available:
		Inputs.action_inputs_enabled = false


func _on_interaction_hit_box_mouse_exited() -> void:
	Inputs.action_inputs_enabled = true

#endregion

# ..............................................................................
