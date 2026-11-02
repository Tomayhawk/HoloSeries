extends SceneBase

# DUNGEON (SCENE)

# ..............................................................................

#region CONSTANTS

const CURRENT_SCENE: Global.Scenes = Global.Scenes.DUNGEON_SCENE_1

#endregion

# ..............................................................................

#region INITIAL

func _ready() -> void:
	add_transit_signal($WorldScene2Transit, Global.Scenes.WORLD_SCENE_2)
	Global.new_scene_ready.emit()

#endregion

# ..............................................................................
