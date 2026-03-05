extends Resource

var effect_type: Entities.Status = Entities.Status.INVINCIBLE
var effect_timer: float = 0.1
var remove_on_death: bool = true

func effect_timeout(stats: EntityStats) -> void:
	stats.effects.erase(self)
	stats.attempt_remove_status(Entities.Status.INVINCIBLE)

func remove_effect(stats: EntityStats) -> void:
	stats.effects.erase(self)
	stats.attempt_remove_status(Entities.Status.INVINCIBLE)
