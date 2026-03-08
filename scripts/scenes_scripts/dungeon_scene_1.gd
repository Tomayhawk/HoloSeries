extends Node2D

# ..............................................................................

# READY

func _ready() -> void:
	Global.new_scene_ready.emit()

# ..............................................................................

# SCENE CHANGES

func _on_world_scene_2_transit_body_entered(body: Node) -> void:
	if not body.is_main_player: return
	$WorldScene2Transit/CollisionShape2D.set_deferred("disabled", true)
	Global.change_scene(Global.Scenes.DUNGEON_SCENE_1, Global.Scenes.WORLD_SCENE_2)

# ..............................................................................
