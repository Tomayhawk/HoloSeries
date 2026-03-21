class_name BasicEnemyBase
extends EnemyBase

# BASIC ENEMY BASE (ENTITY)

# ..............................................................................

#region VARIABLES

var players_in_detection_area: Array[PlayerBase] = []
var players_in_attack_area: Array[PlayerBase] = []

#endregion

# ..............................................................................

#region MOVEMENT AND ACTIONS

func start_walk(temp_direction: Vector2 = Vector2.ZERO) -> void:
	# move in a random direction if no set direction
	if temp_direction == Vector2.ZERO:
		temp_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()

	$Animation.play(&"walk")
	$Animation.flip_h = move_state_velocity.x < 0.0

	move_state_velocity = temp_direction * self.MOVE_SPEED


func set_action_target() -> void:
	# set available targets
	var available_targets: Array[EntityBase]
	if not players_in_attack_area.is_empty():
		available_targets.assign(players_in_attack_area)
	else:
		available_targets.assign(players_in_detection_area)

	# target player by stats
	action_target = Entities.target_entity_by_stats(
			available_targets, action_target_stats, action_target_get_max)

#endregion

# ..............................................................................

#region KNOCKBACK & DEATH

func knockback(base_velocity: Vector2, base_duration: float = BASE_KNOCKBACK_TIME) -> void:
	# GUARD: already taking knockback or stunned -> ignore new knockback
	if in_forced_move_state():
		return

	super(base_velocity, base_duration)

	# knockback animation
	$Animation.play(&"knockback")
	$Animation.flip_h = base_velocity.x > 0
	$Animation.speed_scale = BASE_KNOCKBACK_TIME / move_state_duration


func death() -> void:
	move_state = MoveState.KNOCKBACK

	$Animation.play(&"death")

	players_in_detection_area.clear()
	players_in_attack_area.clear()
	stats.entity_types &= ~Entities.Type.ENEMIES_ON_SCREEN
	Combat.remove_active_enemy(self)

#endregion

# ..............................................................................

#region DETECTION SIGNALS

func _on_detection_area_body_entered(body: PlayerBase) -> void:
	stats.entity_types |= Entities.Type.ENEMIES_IN_COMBAT

	if not players_in_detection_area.has(body):
		players_in_detection_area.append(body)

	Combat.enter_combat()


func _on_detection_area_body_exited(body: PlayerBase) -> void:
	players_in_detection_area.erase(body)
	if players_in_detection_area.is_empty():
		stats.entity_types &= ~Entities.Type.ENEMIES_IN_COMBAT
		Combat.remove_active_enemy(self)

#endregion

# ..............................................................................

#region ATTACK AREA SIGNALS

func _on_attack_area_body_entered(body: PlayerBase) -> void:
	if not players_in_attack_area.has(body):
		players_in_attack_area.append(body)

	action_in_range = true


func _on_attack_area_body_exited(body: PlayerBase) -> void:
	players_in_attack_area.erase(body)
	if players_in_attack_area.is_empty():
		action_in_range = false

#endregion

# ..............................................................................

#region ON SCREEN SIGNALS

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	stats.entity_types |= Entities.Type.ENEMIES_ON_SCREEN


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	stats.entity_types &= ~Entities.Type.ENEMIES_ON_SCREEN

#endregion

# ..............................................................................
