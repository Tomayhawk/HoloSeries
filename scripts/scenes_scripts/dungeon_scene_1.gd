extends SceneBase

# ..............................................................................

#region CONSTANTS

const CURRENT_SCENE: Global.Scenes = Global.Scenes.DUNGEON_SCENE_1

#endregion

# ..............................................................................

#region READY

func _ready() -> void:
	transit_options.append({
		TransitKeys.TRANSIT_AREA: $WorldScene2Transit,
		TransitKeys.NEXT_SCENE: Global.Scenes.WORLD_SCENE_2,
	})

	super()

#endregion

# ..............................................................................
