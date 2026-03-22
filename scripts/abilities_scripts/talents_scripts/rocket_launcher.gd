extends Area2D

# ROCKET LAUNCHER (ABILITY - TALENT)

# TODO: disable bodies recursively and fix homing projectile

# ..............................................................................

#region CONSTANTS

const MANA_COST: float = 8.0
const SPEED: float = 90.0
const DAMAGE: float = 10.0

#endregion

# ..............................................................................

#region VARIABLES

var damage_types: int = (
		Damage.DamageTypes.ENEMY_TARGET
		| Damage.DamageTypes.PHYSICAL
		| Damage.DamageTypes.NO_REFLECT
		| Damage.DamageTypes.NO_COUNTER
)

@onready var caster_base: EntityBase = Players.main_player
@onready var caster_stats: EntityStats = caster_base.stats

#endregion

# ..............................................................................

#region INITIAL

func _ready() -> void:
	hide()

	# request target entity
	Entities.entity_request_ended.connect(fire, CONNECT_ONE_SHOT)
	Entities.request_entities(Entities.Type.ENEMIES_ON_SCREEN, auto_request)

#endregion

# ..............................................................................

#region FUNCTIONS

# target enemy with shortest distance
func auto_request() -> void:
	Entities.choose_entity(Entities.target_entity_by_distance(
			Entities.entities_available, caster_base.position, false))


func fire(target_entity: EntityBase) -> void:
	# check conditions
	if not target_entity or caster_stats.mana < MANA_COST or not caster_stats.alive:
		queue_free()
		return

	caster_stats.update_mana(-MANA_COST)
	position = caster_base.position + Vector2(0, -7)
	$AnimatedSprite2D.play(&"shoot")

	# start despawn timer
	$DespawnComponent.set_despawn_requirements(5.0, 1.0)

	$HomingProjectile.initiate_homing_projectile(target_entity,
			SPEED * (1 + (caster_stats.intelligence / 1000) + (caster_stats.speed / 256)))

	show()


func projectile_collision() -> void:
	Players.camera.screen_shake(5, 1, 20, 20.0)

	var area_of_effect_shape := CircleShape2D.new()
	area_of_effect_shape.radius = 15.0

	for enemy_base in AreaOfEffect.area_of_effect(
			position, Entities.ENEMY_COLLISION_LAYER, area_of_effect_shape):
		if Damage.combat_damage(DAMAGE, damage_types, caster_base.stats, enemy_base.stats):
			enemy_base.knockback((enemy_base.position - position).normalized() * 130.0, 0.6)

	queue_free()

#endregion

# ..............................................................................

#region SIGNALS

func despawn_timeout() -> void:
	projectile_collision()


# on collision,
func _on_body_entered(_enemy_base: EntityBase) -> void:
	projectile_collision()

#endregion

# ..............................................................................
