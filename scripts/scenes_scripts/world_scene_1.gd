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
	Global.change_scene(
			"res://scenes/world_scene_2.tscn",
			Vector2(0, 341),
			[-640, -352, 640, 352] as Array[int],
			"res://music/asmarafulldemo.mp3"
	)

#endregion

# ..............................................................................
