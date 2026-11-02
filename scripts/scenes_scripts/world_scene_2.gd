extends SceneBase

# WORLD SCENE 2 (SCENE)

# ..............................................................................

#region CONSTANTS

const CURRENT_SCENE: Global.Scenes = Global.Scenes.WORLD_SCENE_2

#endregion

# ..............................................................................

#region INITIAL

func _ready() -> void:
	add_transit_signal($WorldScene1Transit, Global.Scenes.WORLD_SCENE_1)
	add_transit_signal($DungeonScene1Transit, Global.Scenes.DUNGEON_SCENE_1)
	Global.new_scene_ready.emit()

#endregion

# ..............................................................................
