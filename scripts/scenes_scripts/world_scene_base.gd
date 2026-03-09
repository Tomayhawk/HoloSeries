class_name SceneBase
extends Node2D

# ..............................................................................

#region CONSTANTS

enum TransitKeys {
	TRANSIT_AREA,
	NEXT_SCENE,
}

#endregion

# ..............................................................................

#region VARIABLES

var transit_options: Array[Dictionary] = []

#endregion

# ..............................................................................

#region READY

func _ready() -> void:
	Global.new_scene_ready.emit()

	for transit in transit_options:
		transit[TransitKeys.TRANSIT_AREA].body_entered.connect(change_scene_transit.bind(
				transit[TransitKeys.TRANSIT_AREA].get_node(^"CollisionShape2D"),
				transit[TransitKeys.NEXT_SCENE]))

#endregion

# ..............................................................................

#region SCENE CHANGE

func change_scene_transit(
		player_base: PlayerBase,
		collision_area: CollisionShape2D,
		next_scene: Global.Scenes
) -> void:

	if not player_base.is_main_player:
		return

	collision_area.set_deferred("disabled", true)
	Global.change_scene(self.CURRENT_SCENE, next_scene)

#endregion

# ..............................................................................
