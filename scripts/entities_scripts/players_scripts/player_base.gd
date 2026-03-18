class_name PlayerBase
extends EntityBase

# PLAYER BASE (PLAYER)

# TODO: deal with all await edge cases in project

# TODO: test and maybe add other knockback options (maybe also dash)
# TODO: fix endless knockback
# TODO: fix unexpected sora slash halts (check action states, move states, and animation updates)
# TODO: fix nousagi stop attacking

#var t = knockback_timer / 0.4
# Quadratic
#velocity = move_state_velocity * t * t
# Exponential
#velocity = move_state_velocity * pow(t, 0.5)
# Ease Out Sine
#velocity = move_state_velocity * sin(t * PI * 0.5)

# ..............................................................................

#region CONSTANTS

# 8-way, normalized, direction vectors, clockwise from RIGHT
const DIRECTION_VECTORS: Array[Vector2] = [
	Vector2.RIGHT,
	Vector2(0.70710678, 0.70710678),
	Vector2.DOWN,
	Vector2(-0.70710678, 0.70710678),
	Vector2.LEFT,
	Vector2(-0.70710678, -0.70710678),
	Vector2.UP,
	Vector2(0.70710678, -0.70710678),
]

const DEAD_ZONE: float = 0.2

#endregion

# ..............................................................................

#region ALLY CONSTANTS

const ALLY_MAX_COMBAT_DIST_SQUARED: float = 202500.0 # 450.0 pixels
const ALLY_MAX_DIST_SQUARED: float = 90000.0 # 300.0 pixels

const ALLY_IDLE_DIST_1_SQUARED: float = 5625.0 # 75.0 pixels
const ALLY_IDLE_DIST_2_SQUARED: float = 10000.0 # 100.0 pixels
const ALLY_IDLE_DIST_3_SQUARED: float = 22500.0 # 150.0 pixels

const ALLY_IDLE_WAIT_1: Vector2 = Vector2(2.4, 2.6) # ally < 75.0 pixels from main player
const ALLY_IDLE_WAIT_2: Vector2 = Vector2(2.0, 2.2) # ally < 100.0 pixels from main player
const ALLY_IDLE_WAIT_3: Vector2 = Vector2(1.6, 1.8) # ally < 150.0 pixels from main player
const ALLY_IDLE_WAIT_4: Vector2 = Vector2(1.2, 1.4) # ally >= 150.0 pixels from main player

const ALLY_SPRINT_DIST_SQUARED: float = 15625.0 # 125.0 pixels

const EIGHT_WAY_INCREMENT: float = PI / 4.0

#endregion

# ..............................................................................

#region VARIABLES

# TODO: entity_types should help set groups
var is_main_player: bool = false:
	set(value):
		is_main_player = value
		set_process_input(is_main_player)

		if is_instance_valid(stats):
			if is_main_player: # ally -> main
				stats.entity_types &= ~Entities.Type.PLAYERS_ALLIES
				stats.entity_types |= Entities.Type.PLAYERS_MAIN
			else: # main -> ally
				stats.entity_types &= ~Entities.Type.PLAYERS_MAIN
				stats.entity_types |= Entities.Type.PLAYERS_ALLIES

var party_index: int = -1:
	set(value):
		Players.party_bases[value] = self
		party_index = value

var basic_attack_node: Node = null
var action_queue: Array[Dictionary] = [] # { "action_node": Node, "priority": int }

#endregion

# ..............................................................................

#region INITIAL

func _ready() -> void:
	Combat.entered_combat.connect(enter_combat)
	Combat.left_combat.connect(end_combat)
	set_process_input(is_main_player)

#endregion

# ..............................................................................

#region PROCESS

func _physics_process(_delta: float) -> void:
	# no velocity if stunned
	if move_state == MoveState.STUN:
		return

	# decrease velocity if taking knockback or dashing
	if move_state == MoveState.KNOCKBACK:
		velocity = move_state_velocity * move_state_timer / 0.4
	elif move_state == MoveState.DASH:
		velocity = move_state_velocity * move_state_timer / stats.dash_time
	# face action target when applicable
	elif not is_main_player and move_state == MoveState.IDLE and action_target:
		action_direction = (action_target.position - position).normalized()
		$Animation.update_animation()

	move_and_slide()

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# GUARD: world inputs disabled -> ignore input
	if not Inputs.world_inputs_enabled:
		return

	# INPUT: left, right, up, down -> apply player movement
	if (
			event.is_action(&"left") or event.is_action(&"right")
			or event.is_action(&"up") or event.is_action(&"down")
	):
		Inputs.accept_event()
		# GUARD: input is echo || player in forced move state -> ignore input
		if not event.is_echo():
			update_main_player_movement()
	# INPUT: dash -> handle dash inputs
	elif event.is_action(&"dash"):
		Inputs.accept_event()
		handle_dash_input(event)

#endregion

# ..............................................................................

#region INPUT FUNCTIONS

func handle_dash_input(event: InputEvent) -> void:
	if event.is_pressed():
		attempt_dash()
	elif move_state == MoveState.SPRINT and not Inputs.sprint_on_release:
		end_sprint()

#endregion

# ..............................................................................

#region MOVEMENT

func apply_movement(next_direction: Vector2) -> void:
	# if no direction, set idle state
	if next_direction == Vector2.ZERO:
		move_state = MoveState.IDLE
		velocity = Vector2.ZERO
		$Animation.update_animation.call_deferred()
		return

	# set velocity
	velocity = next_direction * stats.move_speed

	# update move state or multiply velocity accordingly
	match move_state:
		MoveState.IDLE:
			move_state = MoveState.WALK
		MoveState.SPRINT:
			velocity *= stats.sprint_multiplier
		MoveState.DASH:
			move_state_velocity = velocity * stats.dash_multiplier
			velocity = move_state_velocity * move_state_timer / stats.dash_time

	# update animation
	$Animation.update_animation()


# TODO: need to test
func toggle_text_box(to_enabled: bool) -> void:
	if not stats.alive: return

	set_process(to_enabled)
	set_physics_process(to_enabled)

	if to_enabled:
		move_state_timer = 0.0
		if is_main_player:
			set_process_input(true)
		else:
			_on_move_state_timeout()
	else:
		apply_movement(Vector2.ZERO)
		if is_main_player:
			set_process_input(false)

#endregion

# ..............................................................................

#region MOVE STATES

func _on_move_state_timeout() -> void:
	# reset move state
	move_state_timer = 0.0

	# end forced move states
	if in_forced_move_state():
		move_state = MoveState.IDLE

	if is_main_player:
		if Input.is_action_pressed(&"dash") or Inputs.sprint_on_release:
			move_state = MoveState.SPRINT
		update_main_player_movement()
	else:
		update_ally_movement()


func update_main_player_movement() -> void:
	if not in_forced_move_state():
		apply_movement(Input.get_vector(&"left", &"right", &"up", &"down", DEAD_ZONE))


func in_motion() -> bool:
	return move_state in [MoveState.WALK, MoveState.DASH, MoveState.SPRINT]


func update_ally_movement() -> void:
	# while in action, stay idle
	if in_action():
		move_state_timer = maxf(0.5, action_cooldown)
		apply_movement(Vector2.ZERO)
		return

	var ally_distance: float = position.distance_squared_to(Players.main_player.position)
	var target_direction: Vector2 = Vector2.ZERO

	# if in combat and close to main player
	if Combat.in_combat():
		if ally_distance > ALLY_MAX_COMBAT_DIST_SQUARED:
			ally_teleport()

		# if in action range
		if in_action_range:
			# attempt action on action ready
			if action_state == ActionState.READY:
				ally_attempt_action()
			# else face target
			else:
				ally_set_target()

			# stay idle
			apply_movement(Vector2.ZERO)
			move_state_timer = maxf(0.5, action_cooldown)
			return

		# if not in action range, navigate to the nearest candidate by quality
		action_target = Entities.target_entity_by_distance(Entities.type_entities_array(
				Global.get_tree().get_nodes_in_group(&"enemies_in_combat")), position, false)

		# move towards action target
		$NavigationAgent2D.target_position = action_target.position

		target_direction = to_local($NavigationAgent2D.get_next_path_position())
		move_state_timer = randf_range(0.2, 0.4) / stats.move_speed * stats.MOVE_SPEED_BASE

	# elif large ally distance, teleport to main player
	elif ally_distance > ALLY_MAX_DIST_SQUARED:
		ally_teleport()
		update_ally_movement()
		return

	# elif not in idle, enter idle
	elif move_state != MoveState.IDLE:
		ally_idle(ally_distance)
		return

	# elif ally distance is larger than 75.0 (between 75.0 and 300.0), navigate to main player
	elif ally_distance > ALLY_IDLE_DIST_1_SQUARED:
		# sprint with main player with conditions
		if (
				Players.main_player.move_state == MoveState.SPRINT
				and ally_distance > ALLY_SPRINT_DIST_SQUARED
				and not stats.fatigue
		):
			move_state = MoveState.SPRINT

		$NavigationAgent2D.target_position = Players.main_player.position
		target_direction = to_local($NavigationAgent2D.get_next_path_position())
		move_state_timer = randf_range(0.5, 0.7) / stats.move_speed * stats.MOVE_SPEED_BASE

	# else move randomly (not in combat, and ally distance is less than 75.0)
	else:
		target_direction = Vector2.RIGHT.rotated(randf() * TAU)
		move_state_timer = randf_range(0.5, 0.7) / stats.move_speed * stats.MOVE_SPEED_BASE

	apply_movement(ally_snap_direction(target_direction))


# TODO: need to limit teleportation locations using collisions
func ally_teleport(next_position: Vector2 = Players.main_player.position) -> void:
	if is_main_player: return
	position = next_position + (Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * 25)


func ally_idle(ally_distance: float) -> void:
	var wait_time: Vector2 = (
		ALLY_IDLE_WAIT_1 if ally_distance < ALLY_IDLE_DIST_1_SQUARED
		else ALLY_IDLE_WAIT_2 if ally_distance < ALLY_IDLE_DIST_2_SQUARED
		else ALLY_IDLE_WAIT_3 if ally_distance < ALLY_IDLE_DIST_3_SQUARED
		else ALLY_IDLE_WAIT_4
	)

	move_state_timer = randf_range(wait_time.x, wait_time.y)
	apply_movement(Vector2.ZERO)


func ally_snap_direction(target_direction: Vector2) -> Vector2:
	# snap target direction to the nearest 8-way angle
	var snapped_angle: float = \
			EIGHT_WAY_INCREMENT * roundi(target_direction.angle() / EIGHT_WAY_INCREMENT)

	# GUARD: ShapeCast2D not in tree -> just return snapped angle (for scene changes)
	if not $ObstacleCheck.is_inside_tree():
		return Vector2.RIGHT.rotated(snapped_angle)

	# possible angles by proximity to the snapped angle
	var possible_angles: Array[float] = [
		snapped_angle,
		snapped_angle + EIGHT_WAY_INCREMENT,
		snapped_angle - EIGHT_WAY_INCREMENT,
		snapped_angle + EIGHT_WAY_INCREMENT * 2,
		snapped_angle - EIGHT_WAY_INCREMENT * 2,
		snapped_angle + EIGHT_WAY_INCREMENT * 3,
		snapped_angle - EIGHT_WAY_INCREMENT * 3,
		snapped_angle + EIGHT_WAY_INCREMENT * 4,
	]

	# find the closest non-colliding direction
	for possible_angle in possible_angles:
		# attempt possible direction
		target_direction = Vector2.RIGHT.rotated(possible_angle)

		# check for collisions
		$ObstacleCheck.set_target_position(target_direction * 10.0)
		$ObstacleCheck.force_shapecast_update()

		# if not colliding, break
		if not $ObstacleCheck.is_colliding():
			break

	return target_direction

# DASH

func attempt_dash() -> void:
	# check dash conditions
	if not (stats.can_dash() and move_state in [MoveState.WALK, MoveState.SPRINT]):
		return

	# update dash timer and stamina
	move_state_timer = stats.dash_time
	stats.update_stamina(-stats.dash_stamina)

	# update move state and velocity
	move_state = MoveState.DASH
	apply_movement(velocity.normalized())

# END SPRINT

func end_sprint() -> void:
	move_state = MoveState.WALK
	apply_movement(velocity.normalized())

# KNOCKBACK

func knockback(next_velocity: Vector2, duration: float) -> void:
	# check if move state can be changed
	if in_forced_move_state():
		return

	# update velocity and knockback timer
	move_state_velocity = next_velocity
	move_state_timer = duration

	# update move state and animation
	move_state = MoveState.KNOCKBACK

# STUN

func stun(duration: float) -> void:
	# check if move state can be changed
	if in_forced_move_state():
		return

	# update velocity and stun timer
	velocity = Vector2.ZERO
	move_state_timer = duration

	# update move state and animation
	move_state = MoveState.STUN

#endregion

# ..............................................................................

#region ACTION INPUT

func action_input() -> void:
	# GUARD: not action ready || taking knockback || stunned -> ignore input
	if action_state != ActionState.READY or in_forced_move_state():
		return

	action_direction = \
			(Inputs.get_global_mouse_position() - position).normalized()

	action_node.action_start()

#endregion

# ..............................................................................

#region ALLY ACTIONS

# TODO: should add action selection logic
func ally_queue_action(action: Node = null, priority: int = 0) -> void:
	# action queue limit = 3 actions
	if action_queue.size() > 3:
		return

	# otherwise use basic attack
	if not action:
		# use previous action or basic attack
		if is_instance_valid(action_node):
			action = action_node
		else:
			action = basic_attack_node

	# queue action
	action_queue.append({ "action_node": action, "priority": priority })


# choose action with highest priority
func ally_choose_action() -> void:
	var highest_priority: int = -1
	var chosen_index: int = 0

	for i in action_queue.size():
		if action_queue[i]["priority"] <= highest_priority:
			continue

		highest_priority = action_queue[i]["priority"]
		action_node = action_queue[i]["action_node"]
		chosen_index = i

	action_queue.remove_at(chosen_index)


func ally_set_action() -> void:
	# set action area radius
	$ActionArea/CollisionShape2D.shape.radius = action_node.action_range

	# set action target variables
	action_target = null
	action_target_candidates.clear()
	action_target_types = action_node.target_types
	action_target_stats = action_node.target_stats
	action_target_get_max = action_node.target_get_max

	# force action area update
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = $ActionArea/CollisionShape2D.shape
	query.transform = $ActionArea/CollisionShape2D.global_transform
	query.collision_mask = $ActionArea.collision_mask

	query.collide_with_areas = true
	query.collide_with_bodies = false

	# update action candidates
	for target_dict in Players.get_world_2d().direct_space_state.intersect_shape(query):
		var target_base: EntityBase = target_dict["collider"].get_parent()
		if target_base.stats.entity_types & action_target_types:
			action_target_candidates.append(target_base)

	in_action_range = not action_target_candidates.is_empty()


func ally_set_target() -> void:
	# if taking action, return
	if action_state not in [ActionState.READY, ActionState.COOLDOWN]:
		return

	# if no action candidates, reset action target and return
	if action_target_candidates.is_empty():
		action_target = null
		return

	# set action target
	action_target = Entities.target_entity_by_stats(
			action_target_candidates, action_target_stats, action_target_get_max)

	if not action_target:
		return

	# set action vector
	action_direction = (action_target.position - position).normalized()


func ally_attempt_action() -> void:
	if not action_node:
		ally_queue_action()
		ally_choose_action()
		ally_set_action()

	# TODO: handle edge cases
	ally_set_target()

	# if failed to find action target, wait 0.5 seconds to try again
	if not action_target:
		action_state = ActionState.COOLDOWN
		action_cooldown = 0.5
		return

	# update movement
	apply_movement(Vector2.ZERO)

	# call action
	action_node.action_start()

#endregion

# ..............................................................................

#region UPDATE NODES

func initialize_player(next_stats: PlayerStats, next_party_index: int) -> void:
	# set party index
	party_index = next_party_index

	# set stats
	stats = next_stats
	stats.base = self
	stats.reset_stats()

	# set character animation
	$Animation.sprite_frames = stats.CHARACTER_ANIMATION
	$Animation.play(&"down_idle")

	# set basic attack node
	basic_attack_node = stats.CHARACTER_BASIC_ATTACK.instantiate()
	action_node = basic_attack_node
	add_child(basic_attack_node)

	# update stats ui and stats bars
	Combat.ui.update_party_ui(party_index, stats)


func switch_to_main() -> void:
	# update main player
	is_main_player = true
	Players.main_player = self

	# update camera
	Players.camera.update_camera(self)

	# if not in forced move state, reset move state
	if not in_forced_move_state() and move_state_timer > 0.0:
		_on_move_state_timeout()

	# store and reset action state
	stats.last_action_cooldown = action_cooldown if action_state == ActionState.COOLDOWN else 0.0
	action_cooldown = 0.0
	action_cooldown_timeout.emit()

	# reset action variables
	action_direction = Vector2.ZERO
	in_action_range = false

	stats.entity_types &= ~Entities.Type.PLAYERS_ALLIES
	stats.entity_types |= Entities.Type.PLAYERS_MAIN


func switch_to_ally() -> void:
	is_main_player = false

	# reset entities request
	Entities.end_entities_request()

	# if not in forced move state, reset move state
	if not in_forced_move_state():
		_on_move_state_timeout()

	# update action state and cooldown
	if action_cooldown > 0.0:
		action_cooldown = max(action_cooldown, stats.last_action_cooldown)
	elif stats.last_action_cooldown > 0.0:
		action_state = ActionState.COOLDOWN
		action_cooldown = stats.last_action_cooldown
	else:
		action_state = ActionState.READY

	ally_queue_action()

	stats.entity_types &= ~Entities.Type.PLAYERS_MAIN
	stats.entity_types |= Entities.Type.PLAYERS_ALLIES


func switch_character(next_stats: PlayerStats) -> void:
	stats.base = null
	stats.last_action_cooldown = action_cooldown

	stats = next_stats

	next_stats.base = self
	next_stats.set_base_variables()
	next_stats.update_display_values()

	$Animation.sprite_frames = next_stats.CHARACTER_ANIMATION
	if is_main_player:
		update_main_player_movement()

	action_cooldown = next_stats.last_action_cooldown
	action_state = ActionState.COOLDOWN if action_cooldown > 0.0 else ActionState.READY

	process_interval = 0.0

	# update player ui
	Combat.ui.update_party_ui(party_index, next_stats)

#endregion

# ..............................................................................

#region STATS STATES

func fatigue_state() -> void:
	if move_state in [MoveState.DASH, MoveState.SPRINT]:
		move_state = MoveState.WALK
		$Animation.update_animation()


func death() -> void:
	# pause process and update all base class variables
	super ()

	set_physics_process(false)

	# disable collisions
	toggle_collisions(false)

	# hide stats bars
	$HealthBar.hide()
	$ManaBar.hide()
	$StaminaBar.hide()
	$ShieldBar.hide()

	# handle main player death
	if is_main_player:
		var alive_party_players = Players.get_children().filter(func(node: Node) -> bool: return node.stats.alive)
		if not alive_party_players.is_empty():
			Players.switch_main_player(alive_party_players[0])
		else:
			print("[LOG] [player_base.gd] GAME OVER") # TODO

	# play death animation
	var animation_node: AnimatedSprite2D = $Animation
	animation_node.play(&"death")

	# await death animation finished
	await animation_node.animation_finished

	# pause animation accordingly
	if not stats.alive and animation_node.animation == &"death":
		animation_node.pause()

	stats.entity_types &= ~Entities.Type.PLAYERS_ALIVE
	stats.entity_types |= Entities.Type.PLAYERS_DEAD

func revive() -> void:
	# resume process
	super ()

	set_physics_process(true)

	# enable collisions
	toggle_collisions(true)

	# update animation
	$Animation.animation_finished.emit()
	$Animation.update_animation()

	if Combat.in_combat():
		enter_combat()

	# update variables
	#update_ultimate_gauge(0.0)
	#update_shield(0.0)
	#play(&"down_idle")

	stats.entity_types &= ~Entities.Type.PLAYERS_DEAD
	stats.entity_types |= Entities.Type.PLAYERS_ALIVE

func toggle_collisions(to_enabled: bool) -> void:
	$MovementHitBox.disabled = not to_enabled
	$InteractionArea/CollisionShape2D.disabled = not to_enabled
	$LootableArea/CollisionShape2D.disabled = not to_enabled
	$ActionArea/CollisionShape2D.disabled = not to_enabled

#endregion

# ..............................................................................

#region SIGNALS

# Combat Signals

func enter_combat() -> void:
	if not is_main_player and not in_action():
		move_state_timer = 0.3
		ally_queue_action()
		ally_choose_action()
		ally_set_action()
		ally_attempt_action()


func end_combat() -> void:
	# if is main player or in action, resolve naturally or ignore
	if is_main_player or in_action():
		return

	# reset action variables
	reset_action()
	reset_action_targets()

	action_queue.clear()

# Action State Timer

func _on_action_cooldown_timeout() -> void:
	if action_state == ActionState.DISABLED:
		return

	action_state = ActionState.READY

	if not is_main_player:
		ally_attempt_action()

# CombatHitBox

func _on_combat_hit_box_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if Input.is_action_just_pressed(&"action") and event.is_action_pressed(&"action"):
		if self in Entities.entities_available:
			Inputs.accept_event()
			Entities.choose_entity(self)
		elif Inputs.alt_pressed and not is_main_player:
			Inputs.accept_event()
			Players.switch_main_player(self)


func _on_combat_hit_box_mouse_entered() -> void:
	if self in Entities.entities_available or Inputs.alt_pressed:
		Inputs.action_inputs_enabled = false
		Inputs.zoom_inputs_enabled = false


func _on_combat_hit_box_mouse_exited() -> void:
	Inputs.action_inputs_enabled = true
	Inputs.zoom_inputs_enabled = true

# InteractionArea

func _on_interaction_area_body_entered(body: Node2D) -> void:
	body.interaction_area(self, true)


func _on_interaction_area_body_exited(body: Node2D) -> void:
	body.interaction_area(self, false)

# LootableArea

func _on_lootable_area_area_entered(body: Node2D) -> void:
	body.player_entered(self)


func _on_lootable_area_area_exited(body: Node2D) -> void:
	body.player_exited(self)

# ActionArea

func _on_action_area_body_entered(body: Node2D) -> void:
	# if is main player, ignore
	if is_main_player:
		return

	# if body does not match any action target types, ignore
	if not body.stats.entity_types & action_target_types:
		return

	# if body is already a candidate, ignore
	if action_target_candidates.has(body):
		return

	# update action target variables
	action_target_candidates.append(body)
	in_action_range = true

	# attempt action if ready
	if action_state == ActionState.READY:
		ally_attempt_action()


func _on_action_area_body_exited(body: Node2D) -> void:
	action_target_candidates.erase(body)
	in_action_range = not action_target_candidates.is_empty()

	if not is_main_player and not in_action_range:
		_on_move_state_timeout()

#endregion

# ..............................................................................
