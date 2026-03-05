extends Area2D

# ..............................................................................

#region CONSTANTS

const DAMAGE_TYPES: int = \
		Damage.DamageTypes.ENEMY_HIT | \
		Damage.DamageTypes.COMBAT | \
		Damage.DamageTypes.PHYSICAL

const MANA_COST: float = 8.0

#endregion

# ..............................................................................

#region VARIABLES

var speed: float = 90.0
var damage: float = 10.0

@onready var caster_base: EntityBase = Players.main_player
@onready var caster_stats: EntityStats = caster_base.stats

#endregion

# ..............................................................................

#region FUNCTIONS

func _ready() -> void:
	hide()

	# request target entity
	Entities.entity_request_ended.connect(entity_chosen, CONNECT_ONE_SHOT)
	Entities.request_entities(Entities.Type.ENEMIES_ON_SCREEN)

	# if alt is pressed, auto-aim closest enemy
	if Inputs.alt_pressed:
		Entities.choose_entity(Entities.target_entity_by_distance(Entities.entities_available, caster_base.position, false))


func entity_chosen(target_entity: EntityBase) -> void:
	# check conditions
	if not target_entity or caster_stats.mana < MANA_COST or not caster_stats.alive:
		queue_free()
		return

	caster_stats.update_mana(-MANA_COST)

	position = caster_base.position + Vector2(0, -7)

	$AnimatedSprite2D.play(&"shoot")
	$HomingProjectile.initiate_homing_projectile(target_entity,
			speed * (1 + (caster_stats.intelligence / 1000) + (caster_stats.speed / 256)))
	$AreaOfEffect.collision_mask |= 1 << 1
	$AreaOfEffect/CollisionShape2D.scale = Vector2(1.5, 1.5)
	$DespawnComponent.set_despawn_requirements(5.0, 1.0)

	show()


func projectile_collision(move_direction) -> void:
	await Players.camera.screen_shake(5, 1, 20, 20.0)
	var target_enemy_bases: Array[EntityBase] = await $AreaOfEffect.area_of_effect(2)
	for enemy_base in target_enemy_bases:
		if Damage.combat_damage(damage, DAMAGE_TYPES, caster_base.stats, enemy_base.stats):
			enemy_base.knockback(move_direction, 1.5)
	queue_free()

#endregion

# ..............................................................................

#region FUNCTIONS

func despawn_timeout() -> void:
	# TODO: temporary code
	projectile_collision(Vector2.ZERO)


# on collision,
func _on_body_entered(_body: Node2D) -> void:
	# TODO: temporary code
	projectile_collision(Vector2.ZERO)

#endregion

# ..............................................................................
