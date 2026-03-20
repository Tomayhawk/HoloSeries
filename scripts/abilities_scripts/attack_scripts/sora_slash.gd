extends ShapeCast2D

# SORA SLASH (ATTACK)

# ..............................................................................

#region CONSTANTS

const OFFSET_POSITION: Vector2 = Vector2(0.0, -7.0)
const ACTION_TYPE: PlayerBase.ActionType = PlayerBase.ActionType.MELEE

const DAMAGE_TYPES: int = \
		Damage.DamageTypes.ENEMY_TARGET | \
		Damage.DamageTypes.PHYSICAL

const CAMERA_SHAKE: Array = [5, 1, 10, 10.0]
const BASE_DAMAGE: float = 10.0
const DASH_ATTACK_MULTIPLIER: float = 1.5
const COOLDOWN_RANGE: Vector2 = Vector2(0.4, 0.7)

#endregion

# ..............................................................................

#region VARIABLES

# action variables
var action_range: float = 20.0
var target_types: int = Entities.Type.ENEMIES
var target_stats: StringName = &"health"
var target_get_max: bool = false

# reference nodes
@onready var player_base: PlayerBase = get_parent()
@onready var animation_node: AnimatedSprite2D = get_parent().get_node(^"Animation")

#endregion

# ..............................................................................

#region INITIAL

func _ready() -> void:
	position = OFFSET_POSITION

#endregion

# ..............................................................................

#region ACTION STATES

# ActionState.READY -> ActionState.WINDUP
func action_start() -> void:
	# GUARD: ShapeCast2D not in tree -> end action
	if not is_inside_tree():
		return

	# update player action type and state
	player_base.action_type = ACTION_TYPE
	player_base.action_state = player_base.ActionState.WINDUP

	# update slash direction
	set_target_position(player_base.action_direction * action_range)
	force_shapecast_update()

	animation_node.update_animation()

	# connect signals
	animation_node.animation_changed.connect(action_disrupted, CONNECT_ONE_SHOT)
	animation_node.frame_changed.connect(action_execute, CONNECT_ONE_SHOT)


# ActionState.WINDUP -> ActionState.EXECUTE
func action_execute() -> void:
	player_base.action_state = player_base.ActionState.EXECUTE

	# handle collision
	if is_colliding():
		action_collision()

	animation_node.frame_changed.connect(action_recovery, CONNECT_ONE_SHOT)


# ActionState.EXECUTE -> ActionState.RECOVERY
func action_recovery() -> void:
	player_base.action_state = player_base.ActionState.RECOVERY

	animation_node.animation_finished.connect(action_complete, CONNECT_ONE_SHOT)


# ActionState.RECOVERY -> ActionState.COOLDOWN
func action_complete() -> void:
	animation_node.animation_changed.disconnect(action_disrupted)

	if player_base.is_main_player:
		player_base.action_state = player_base.ActionState.READY
	else:
		player_base.action_state = player_base.ActionState.COOLDOWN
		player_base.action_cooldown = randf_range(COOLDOWN_RANGE.x, COOLDOWN_RANGE.y)

	player_base.action_type = player_base.ActionType.NONE
	player_base.action_direction = Vector2.ZERO

	animation_node.update_animation()

#endregion

# ..............................................................................

#region HELPER FUNCTIONS

func action_collision() -> void:
	Players.camera.screen_shake.callv(CAMERA_SHAKE)

	var damage: float = BASE_DAMAGE
	var knockback_weight: float = player_base.stats.force

	# handle dash attack
	if player_base.move_state == player_base.MoveState.DASH:
		damage *= DASH_ATTACK_MULTIPLIER
		knockback_weight *= DASH_ATTACK_MULTIPLIER

	# handle enemy damage and knockback
	for collision_index in get_collision_count():
		var enemy_base: EnemyBase = get_collider(collision_index).get_parent()

		if not is_instance_valid(player_base) or not is_instance_valid(enemy_base):
			continue

		if Damage.combat_damage(damage, DAMAGE_TYPES, player_base.stats, enemy_base.stats):
			enemy_base.knockback(player_base.action_direction * 90.0 * knockback_weight, 0.5)


# GUARD: animation changed during action -> disconnect from all animation signals
func action_disrupted() -> void:
	if animation_node.frame_changed.is_connected(action_execute):
		animation_node.frame_changed.disconnect(action_execute)
	elif animation_node.frame_changed.is_connected(action_recovery):
		animation_node.frame_changed.disconnect(action_recovery)
	elif animation_node.animation_finished.is_connected(action_complete):
		animation_node.animation_finished.disconnect(action_complete)


func action_cleanup() -> void:
	pass

#endregion

# ..............................................................................
