extends SceneBase

# ..............................................................................

#region CONSTANTS

const CURRENT_SCENE: Global.Scenes = Global.Scenes.WORLD_SCENE_2

#endregion

# ..............................................................................

#region READY

func _ready() -> void:
	transit_options.append({
		TransitKeys.TRANSIT_AREA: $WorldScene1Transit,
		TransitKeys.NEXT_SCENE: Global.Scenes.WORLD_SCENE_1,
	})

	transit_options.append({
		TransitKeys.TRANSIT_AREA: $DungeonScene1Transit,
		TransitKeys.NEXT_SCENE: Global.Scenes.DUNGEON_SCENE_1,
	})

	super()

#endregion

# ..............................................................................
