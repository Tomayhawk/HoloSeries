extends BasicEnemyBase

# NOUSAGI (ENEMY)

# ..............................................................................

#region CONSTANTS

const ENEMY_BASE_STATS: Dictionary[StringName, float] = {
	# health, mana and stamina
	&"base_health": 9999.0,
	&"base_mana": 10.0,
	&"base_stamina": 150.0,

	# basic stats
	&"base_defense": 10.0,
	&"base_ward": 10.0,
	&"base_strength": 10.0,
	&"base_intelligence": 10.0,
	&"base_speed": 0.0,
	&"base_agility": 0.0,
	&"base_crit_chance": 0.05,
	&"base_crit_damage": 1.50,

	# secondary stats
	&"base_force": 1.0,
	&"base_weight": 1.0,
	&"base_vision": 1.0,
}

const MOVE_SPEED: float = 45.0

const ATTACK_DAMAGE_TYPES: int = Damage.DamageTypes.PLAYER_TARGET | Damage.DamageTypes.PHYSICAL

const NOUSAGI_PRELOAD: PackedScene = preload("res://entities/enemies/basic_enemies/nousagi.tscn")
const DEATH_LOOT: Array = Inventory.LOOTABLES[Inventory.LootablesKeys.TEMP_SHIRAKAMI]

# indicator offsets
const MARKER_OFFSET: float = -40.0
const HIGHLIGHT_OFFSET: float = 5.0

#endregion

# ..............................................................................

#region INITIAL

func _init() -> void:
	# set stats
	stats = BasicEnemyStats.new()
	stats.base = self
	stats.set_enemy_base_stats(self.ENEMY_BASE_STATS)
	stats.reset_current_stats()

	# set action target variables
	action_target_types = Entities.Type.PLAYERS_ALIVE
	action_target_stats = &"health"
	action_target_get_max = false


func _ready() -> void:
	animation_end()

#endregion

# ..............................................................................

#region PROCESS

func _physics_process(_delta: float) -> void:
	# handle knockback
	if move_state == MoveState.KNOCKBACK:
		velocity = move_state_velocity * sin(move_state_timer / move_state_duration * PI * 0.5)
	# handle idle state
	elif move_state == MoveState.IDLE and action_target:
		$Animation.flip_h = action_target.position.x < position.x
		if action_state == ActionState.READY:
			take_action()

	move_and_slide()

#endregion

# ..............................................................................

#region ANIMATION

func animation_end() -> void:
	# GUARD: handle scene pauses
	if process_mode == PROCESS_MODE_DISABLED:
		$Animation.play(&"idle")
		return

	# GUARD: handle death
	if not stats.alive:
		handle_death()
		return

	# GUARD: handle attack state
	if action_state == ActionState.RECOVERY:
		action_state = ActionState.COOLDOWN
		action_cooldown = randf_range(1.5, 3.0)

	# reset move state
	velocity = Vector2.ZERO
	move_state_velocity = Vector2.ZERO
	move_state = MoveState.IDLE
	$Animation.speed_scale = 1.0

	# idle near player
	if action_in_range:
		set_action_target()
		action_direction = (action_target.position - position).normalized()
		$Animation.play(&"idle")
		$Animation.flip_h = action_direction.x < 0.0
	# move towards nearby player
	elif action_target:
		$NavigationAgent2D.target_position = action_target.position
		start_walk(to_local($NavigationAgent2D.get_next_path_position()).normalized())
	# else move in a random direction
	else:
		start_walk()


func _on_animation_frame_changed() -> void:
	if in_forced_move_state(): return

	if $Animation.frame == 3:
		match $Animation.animation:
			&"attack":
				attack_damage()
			&"walk":
				velocity = move_state_velocity
				move_state = MoveState.WALK


func handle_death() -> void:
	for i in 3:
		var item: Node = LOOTABLES_PRELOAD.instantiate()
		item.instantiate_item.callv([position] + DEATH_LOOT)

	queue_free()

#endregion

# ..............................................................................

#region ACTION

func take_action() -> void:
	if in_forced_move_state(): return

	# attempt summon
	if $SummonCooldown.is_stopped() and randi() % 3 == 0:
		summon_nousagi()
	else:
		start_attack()


func start_attack() -> void:
	action_state = ActionState.WINDUP
	action_direction = (action_target.position - position).normalized()

	$Animation.play(&"attack")
	$Animation.flip_h = action_target.position.x < position.x


func attack_damage() -> void:
	action_state = ActionState.EXECUTE

	if action_target:
		action_direction = (action_target.position - position).normalized()

		var area_of_effect_shape := CircleShape2D.new()
		area_of_effect_shape.radius = 15.0

		for player_base in AreaOfEffect.area_of_effect(
			position + action_direction * 35.0, Entities.PLAYER_COLLISION_LAYER, area_of_effect_shape):
			if Damage.combat_damage(13.0, ATTACK_DAMAGE_TYPES, stats, player_base.stats):
				player_base.knockback(action_direction * 50.0, 0.4)

		$Animation.flip_h = action_direction.x < 0

	action_state = ActionState.RECOVERY


func summon_nousagi() -> void:
	# create an instance of nousagi in enemies node
	var nousagi_instance: Node = NOUSAGI_PRELOAD.instantiate()
	add_sibling(nousagi_instance)
	nousagi_instance.position = position + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * 25

	# start cooldown
	action_cooldown = randf_range(2.0, 3.5)
	action_state = ActionState.COOLDOWN
	$SummonCooldown.start(randf_range(25.0, 40.0))


func action_complete() -> void:
	pass


#endregion

# ..............................................................................

#region HEALTH BAR

# update health bar
func update_health() -> void:
	$HealthBar.visible = stats.health > 0.0 and stats.health < stats.max_health
	$HealthBar.max_value = stats.max_health
	$HealthBar.value = stats.health

	var health_bar_percentage = stats.health / stats.max_health
	$HealthBar.modulate = \
			"a9ff30" if health_bar_percentage > 0.5 \
			else "c8a502" if health_bar_percentage > 0.2 \
			else "a93430"

#endregion

# ..............................................................................

#region SIGNALS

func _on_action_cooldown_timeout() -> void:
	if action_in_range:
		action_state = ActionState.READY
	else:
		pass # TODO

#endregion

# ..............................................................................
