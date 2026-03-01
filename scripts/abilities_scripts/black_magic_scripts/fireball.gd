extends Area2D

# ABILITY NAME: FIREBALL
# ABILITY TYPE: BLACK MAGIC

# ..............................................................................

#region CONSTANTS

const DT := Damage.DamageTypes
const DAMAGE_TYPES: int = DT.ENEMY_HIT | DT.COMBAT | DT.MAGIC

const MANA_COST: float = 8.0
const DAMAGE: float = 10.0
const SPEED: float = 90.0

#endregion

# ..............................................................................

#region VARIABLES

var velocity: Vector2 = Vector2.ZERO

@onready var caster_node: EntityBase = Players.main_player
@onready var caster_stats: EntityStats = caster_node.stats

#endregion

# ..............................................................................

#region PROCESS

func _ready() -> void:
	set_physics_process(false)
	hide()

	# request target entity
	Entities.entities_request_ended.connect(entity_chosen, CONNECT_ONE_SHOT)
	Entities.request_entities(Entities.Type.ENEMIES_ON_SCREEN)

	# if alt is pressed, target nearest enemy
	if Inputs.alt_pressed:
		Entities.choose_entity(Entities.target_entity_by_distance(Entities.entities_available, caster_node.position, false))

func _physics_process(delta: float) -> void:
	position += velocity * delta

#endregion

# ..............................................................................

#region FUNCTIONS

func entity_chosen(chosen_nodes: Array[EntityBase]) -> void:
	var target_node: EntityBase = null

	# check chosen entities
	if not chosen_nodes.is_empty():
		target_node = chosen_nodes[0]

	#
	if not target_node or caster_stats.mana < MANA_COST or not caster_stats.alive:
		queue_free()
		return

	caster_stats.update_mana(-MANA_COST)
	# begin despawn timer
	%AnimatedSprite2D.play(&"shoot")
	position = caster_node.position + Vector2(0, -7)
	%DespawnComponent.set_despawn_requirements(5.0, 1.0)

	velocity = (target_node.position - caster_node.position - Vector2(0, -7)).normalized() * SPEED \
			* (1 + (caster_stats.intelligence / 1000) + (caster_stats.speed / 256))
	set_physics_process(true)
	show()

func projectile_collision(move_direction) -> void:
	await Players.camera.screen_shake(5, 1, 10, 10.0)

	for enemy_node in $AreaOfEffect.area_of_effect(Entities.ENEMY_COLLISION_LAYER):
		if Damage.combat_damage(DAMAGE, DAMAGE_TYPES, caster_node.stats, enemy_node.stats):
			enemy_node.knockback(move_direction, 0.5)

	queue_free()

func despawn_timeout():
	projectile_collision(velocity.normalized())

# on collision,
func _on_body_entered(_body: Node2D) -> void:
	projectile_collision(velocity.normalized())

#endregion

# ..............................................................................
