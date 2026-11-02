class_name SceneBase
extends Node2D

# WORLD SCENE BASE (SCENE)

# ..............................................................................

#region SCENE CHANGE FUNCTIONS

func add_transit_signal(transit_area: Area2D, next_scene: Global.Scenes) -> void:
	transit_area.body_entered.connect(transit_change_scene.bind(
			transit_area.get_node(^"CollisionShape2D"), next_scene))


func transit_change_scene(
		player_base: PlayerBase,
		collision_area: CollisionShape2D,
		next_scene: Global.Scenes
) -> void:
	# trigger scene change only for main player
	if not player_base.is_main_player:
		return

	# scene change
	collision_area.set_deferred("disabled", true)
	Global.change_scene(self.CURRENT_SCENE, next_scene)

#endregion

# ..............................................................................
