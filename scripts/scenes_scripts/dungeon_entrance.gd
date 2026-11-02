extends SceneBase

# WORLD SCENE 1 (SCENE)

# ..............................................................................

#region CONSTANTS

const CURRENT_SCENE: Global.Scenes = Global.Scenes.DUNGEON_ENTRANCE

#endregion

# ..............................................................................

#region INITIAL

func _ready() -> void:
	Global.new_scene_ready.emit()

#endregion

# ..............................................................................
