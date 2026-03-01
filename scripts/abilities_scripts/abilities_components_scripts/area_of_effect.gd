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

	var entities: Array[EntityBase] = []
	for target_dict in get_world_2d().direct_space_state.intersect_shape(query):
		var target_node: EntityBase = target_dict["collider"].get_parent()
		if target_node.stats.alive:
			entities.append(target_node)

	print("AOE ", entities)

	# return entities
	return entities

#endregion

# ..............................................................................
