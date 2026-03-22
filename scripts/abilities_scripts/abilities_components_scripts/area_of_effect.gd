class_name AreaOfEffect
extends Object

# AREA OF EFFECT (ABILITIES COMPONENTS)

# ..............................................................................

#region FUNCTIONS

# trigger AOE and return entities in the area
static func area_of_effect(
		set_position: Vector2, set_collision_mask: int, set_shape: Shape2D
) -> Array[EntityBase]:

	var query := PhysicsShapeQueryParameters2D.new()
	query.transform = Transform2D(0.0, set_position)
	query.collision_mask = set_collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.shape = set_shape

	var entity_bases: Array[EntityBase] = []
	for target_dict in Players.get_world_2d().direct_space_state.intersect_shape(query):
		entity_bases.append(target_dict["collider"].get_parent())

	# return entities
	return entity_bases

#endregion

# ..............................................................................
