extends AnimatedSprite2D

# SPAWNER (WORLD OBJECT)

# ..............................................................................

#region VARIABLES

@export var enemy_path: String = "res://entities/enemies/basic_enemies/nousagi.tscn"
@export var spawn_limit: int = 20

#endregion

# ..............................................................................

#region FUNCTIONS

func can_interact() -> bool:
	return true

func interact() -> void:
	if $Timer.is_stopped():
		$Timer.start()
	else:
		$Timer.stop()

func _on_timer_timeout() -> void:
	if Global.get_tree().get_nodes_in_group(StringName(name)).size() > spawn_limit: return
	var enemy_instance: EnemyBase = Entities.add_enemy_to_scene(load(enemy_path), position, 25.0)
	enemy_instance.add_to_group(StringName(name))

#endregion

# ..............................................................................
