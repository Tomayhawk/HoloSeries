extends ShapeCast2D

# ..............................................................................

#region CONSTANTS

# TODO: make variables for magic numbers
const OFFSET_POSITION: Vector2 = Vector2(0.0, -7.0)
const BASE_DAMAGE: float = 10.0

const ATTACK_ANIMATIONS: Array[StringName] = \
		[&"up_attack", &"down_attack", &"left_attack", &"right_attack"]

const DAMAGE_TYPES: int = \
		Damage.DamageTypes.ENEMY_HIT | \
		Damage.DamageTypes.COMBAT | \
		Damage.DamageTypes.PHYSICAL

const CAMERA_SHAKE: Array = [5, 1, 10, 10.0]

const DASH_ATTACK_MULTIPLIER: float = 1.5

#endregion

# ..............................................................................

#region VARIABLES

# action variables
var action_type: PlayerBase.ActionType = PlayerBase.ActionType.MELEE
var action_range: float = 20.0
var target_types: int = Entities.Type.ENEMIES
var target_stats: StringName = &"health"
var target_get_max: bool = false

# reference nodes
@onready var player_base: PlayerBase = get_parent()
@onready var animation_node: AnimatedSprite2D = get_parent().get_node(^"Animation")

#endregion

# ..............................................................................

#region PROCESS

func _ready() -> void:
	position = OFFSET_POSITION

#endregion

# ..............................................................................

#region FUNCTIONS

# ActionState.READY -> ActionState.WINDUP
func action_start() -> void:
	# set player action states
	player_base.action_state = player_base.ActionState.WINDUP
	player_base.action_type = PlayerBase.ActionType.MELEE

	# set action vector based on mouse position or action target
	if player_base.is_main_player:
		player_base.action_direction = \
				(Inputs.get_global_mouse_position() - player_base.position).normalized()

	set_target_position(player_base.action_direction * action_range)

	force_shapecast_update()

	player_base.update_animation()

	animation_node.frame_changed.connect(action_execute, CONNECT_ONE_SHOT)


# ActionState.WINDUP -> ActionState.EXECUTE
func action_execute() -> void:
	if not animation_node.animation in ATTACK_ANIMATIONS:
		return

	player_base.action_state = player_base.ActionState.EXECUTE

	# handle collision
	if is_colliding():
		await Players.camera.screen_shake.callv(CAMERA_SHAKE)

		# TODO: move dash attack logic to Damage.combat_damage()
		var enemy_body = null
		var dash_attack: bool = player_base.move_state == player_base.MoveState.DASH
		var damage: float = BASE_DAMAGE * (DASH_ATTACK_MULTIPLIER if dash_attack else 1.0)
		var knockback_weight = DASH_ATTACK_MULTIPLIER if dash_attack else 1.0

		for collision_index in get_collision_count():
			enemy_body = get_collider(collision_index).get_parent()

			if not is_instance_valid(player_base) or not is_instance_valid(enemy_body):
				continue

			# TODO: put these two together into a new function
			if Damage.combat_damage(damage, DAMAGE_TYPES, player_base.stats, enemy_body.stats):
				enemy_body.knockback(player_base.action_direction, knockback_weight)

	animation_node.frame_changed.connect(action_recovery, CONNECT_ONE_SHOT)


# ActionState.EXECUTE -> ActionState.RECOVERY
func action_recovery() -> void:
	if not animation_node.animation in ATTACK_ANIMATIONS:
		return

	player_base.action_state = player_base.ActionState.RECOVERY

	animation_node.animation_finished.connect(action_complete, CONNECT_ONE_SHOT)


# ActionState.RECOVERY -> ActionState.COOLDOWN
func action_complete() -> void:
	if not animation_node.animation in ATTACK_ANIMATIONS:
		return

	if player_base.is_main_player:
		player_base.action_state = player_base.ActionState.READY
	else:
		player_base.action_state = player_base.ActionState.COOLDOWN
		player_base.action_cooldown = randf_range(0.4, 0.7)

	player_base.action_type = player_base.ActionType.NONE

	player_base.update_animation()


# ActionState.COOLDOWN -> ActionState.READY
func action_cleanup() -> void:
	pass

#endregion

# ..............................................................................
