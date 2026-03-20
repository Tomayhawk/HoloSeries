class_name BasicEnemyBase
extends EnemyBase

# BASIC ENEMY BASE

# ..............................................................................

#region VARIABLES

var players_in_detection_area: Array[Node] = []
var players_in_attack_area: Array[Node] = []

#endregion

# ..............................................................................

#region KNOCKBACK & DEATH

func knockback(base_velocity: Vector2, base_duration: float = BASE_KNOCKBACK_TIME) -> void:
	# GUARD: already taking knockback or stunned -> ignore new knockback
	if in_forced_move_state():
		return

	super(base_velocity, base_duration)

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

#region SIGNALS

# INTERACTION HIT BOX

func _on_interaction_hit_box_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed(&"action"):
		print("here")
		if Inputs.alt_pressed:
			Inputs.accept_event()
			Combat.lock(self)
		elif self in Entities.entities_available:
			Inputs.accept_event()
			Entities.choose_entity(self)

# DETECTION AREA

func _on_detection_area_body_entered(body: Node2D) -> void:
	if not stats.alive or not body.stats.alive:
		return

	stats.entity_types |= Entities.Type.ENEMIES_IN_COMBAT

	if not players_in_detection_area.has(body):
		players_in_detection_area.append(body)

	Combat.enter_combat()


func _on_detection_area_body_exited(body: Node2D) -> void:
	players_in_attack_area.erase(body)
	players_in_detection_area.erase(body)
	if players_in_attack_area.is_empty() and action_state != ActionState.EXECUTE:
		in_action_range = false
	if players_in_detection_area.is_empty():
		stats.entity_types &= ~Entities.Type.ENEMIES_IN_COMBAT
		Combat.remove_active_enemy(self)

# ATTACK AREA

func _on_attack_area_body_entered(body: Node2D) -> void:
	if not stats.alive or not body.stats.alive:
		return

	if not players_in_detection_area.has(body):
		players_in_detection_area.append(body)

	if not players_in_attack_area.has(body):
		players_in_attack_area.append(body)

	stats.entity_types |= Entities.Type.ENEMIES_IN_COMBAT
	in_action_range = true


func _on_attack_area_body_exited(body: Node2D) -> void:
	players_in_attack_area.erase(body)
	if players_in_attack_area.is_empty():
		in_action_range = false

# ON SCREEN STATUS

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	stats.entity_types |= Entities.Type.ENEMIES_ON_SCREEN


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	stats.entity_types &= ~Entities.Type.ENEMIES_ON_SCREEN

#endregion

# ..............................................................................
