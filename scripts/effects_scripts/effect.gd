class_name Effect
extends RefCounted

# ..............................................................................

#region VARIABLES

var effect_name: String = "EFFECT"
var effect_type: Entities.Status = Entities.Status.NONE
var effect_timer: float = 1.0
var remove_on_death: bool = true

#endregion

# ..............................................................................

#region FUNCTIONS

func set_effect_stats(_stats: EntityStats) -> void:
	pass


func effect_timeout(stats: EntityStats) -> void:
	remove_effect(stats)


func remove_effect(stats: EntityStats) -> void:
	stats.effects.erase(self)
	stats.update_status(effect_type)

#endregion

# ..............................................................................
