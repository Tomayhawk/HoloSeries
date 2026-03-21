class_name EnemyBase
extends EntityBase

# ENEMY BASE (ENTITY)

# ..............................................................................

#region CONSTANTS

const LOOTABLES_PRELOAD = preload("res://entities/lootables/lootable_base.tscn")

#endregion

# ..............................................................................

#region INTERACTION HIT BOX SIGNALS

func _on_interaction_hit_box_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed(&"action"):
		if self in Entities.entities_available:
			Inputs.accept_event()
			Entities.choose_entity(self)
		elif Inputs.alt_pressed:
			Inputs.accept_event()
			if Combat.locked_enemy_base != self:
				Combat.lock_enemy(self)
			else:
				Combat.unlock_enemy()

#endregion

# ..............................................................................
