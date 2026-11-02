extends Sprite2D

# SPAWNER (INTERACTABLE)

# ..............................................................................

#region VARIABLES

@export var enemy_path: String = "res://entities/enemies/basic_enemies/nousagi.tscn"
@export var spawn_limit: int = 20

#endregion

# ..............................................................................

#region FUNCTIONS

func toggle_highlight() -> void:
	texture.region.position.x = 96.0 if texture.region.position.x == 64.0 else 64.0


func attempt_interact() -> void:
	if $Timer.is_stopped():
		$Timer.start()
		texture.region.position.y = 176.0
	else:
		$Timer.stop()
		texture.region.position.y = 208.0

#endregion

# ..............................................................................

#region SIGNALS

func _on_timer_timeout() -> void:
	if Global.get_tree().get_nodes_in_group(StringName(name)).size() > spawn_limit:
		return

	var enemy_instance: EnemyBase = \
			Entities.add_enemy_to_scene(load(enemy_path), position, 25.0)

	if enemy_instance:
		enemy_instance.add_to_group(StringName(name))

#endregion

# ..............................................................................
