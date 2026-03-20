class_name BasicEnemyStats
extends EnemyStats

# ..............................................................................

#region INITIAL

func _init() -> void:
	entity_types |= Entities.Type.ENEMIES | Entities.Type.ENEMIES_BASIC

#endregion

# ..............................................................................

#region FUNCTIONS

func stats_process(stats_process_interval: float) -> void:
	# decrease effects timers
	for effect in effects.duplicate():
		effect.effect_timer -= stats_process_interval
		if effect.effect_timer <= 0.0:
			effect.effect_timeout(self)

#endregion

# ..............................................................................

#region STATS UPDATES

func update_health(value: float) -> void:
	super(value)
	if base: base.update_health()


func update_shield(value: float) -> void:
	super(value)
	if base: base.update_shield()

#endregion

# ..............................................................................

#region SET STATS

# TODO
func set_stats() -> void:
	pass

#endregion

# ..............................................................................
