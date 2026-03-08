extends Node2D

# ..............................................................................

#region READY

func _ready() -> void:
	Global.new_scene_ready.emit()

#endregion

# ..............................................................................

#region SCENE CHANGE

func _on_world_scene_2_transit_body_entered(body: Node) -> void:
	if not body.is_main_player: return
	$WorldScene2Transit/CollisionShape2D.set_deferred("disabled", true)
	Global.change_scene(Global.Scenes.WORLD_SCENE_1, Global.Scenes.WORLD_SCENE_2)

#endregion

# ..............................................................................
