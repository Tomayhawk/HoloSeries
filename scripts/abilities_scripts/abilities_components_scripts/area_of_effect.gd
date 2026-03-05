extends Node2D

# ABILITIES COMPONENT: AREA OF EFFECT

# ..............................................................................

#region FUNCTIONS

# trigger AOE and return entities in the area
func area_of_effect(collision_masks: int) -> Array[EntityBase]:
	var query := PhysicsShapeQueryParameters2D.new()
	query.transform = global_transform
	query.collision_mask = collision_masks
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.shape = CircleShape2D.new()
	query.shape.radius = 10.0

	var entity_bases: Array[EntityBase] = []
	for target_dict in get_world_2d().direct_space_state.intersect_shape(query):
		var target_base: EntityBase = target_dict["collider"].get_parent()
		if target_base.stats.alive:
			entity_bases.append(target_base)

	# return entities
	return entity_bases

#endregion

# ..............................................................................
