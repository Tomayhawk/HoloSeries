extends Node2D

# HOLONEXUS

# ..............................................................................

#region CONSTANTS

const DATA: RefCounted = preload("res://scripts/holo_nexus_scripts/nexus_data.gd")

const CAMERA_LIMITS: Array[int] = [-679, -592, 681, 592]

const UNLOCKABLES_OUTLINE: Resource = \
		preload("res://holo_nexus/nexus_components/nexus_unlockables_outline.tscn")

#endregion

# ..............................................................................

#region VARIABLES

# character variables
var character_stats: Array[PlayerStats] = set_characters()
var current_stats: PlayerStats = Players.main_player.stats
var current_index: int = character_stats.find(current_stats)
var unlockable_nodes: Array[int] = []
var converted_nodes: Array[int] = []

var item_selected: int = -1

# world scene camera settings
var scene_camera_zoom: Vector2 = Players.camera.zoom
var scene_camera_limits: Array[int] = [
	Players.camera.limit_left,
	Players.camera.limit_top,
	Players.camera.limit_right,
	Players.camera.limit_bottom
]

# nodes
@onready var ui: CanvasLayer = $HoloNexusUi
@onready var nexus_player: CharacterBody2D = $NexusPlayer
@onready var nexus_nodes: Array[Node] = $NexusNodes.get_children()

#endregion

# ..............................................................................

#region READY

func _init() -> void:
	Players.camera.force_black_screen(true)
	Players.camera.position_smoothing_enabled = false


func _ready() -> void:
	# update camera
	Players.camera.update_camera($NexusPlayer, Vector2(1.0, 1.0))
	Players.camera.update_camera_limits(CAMERA_LIMITS)

	# initialize nodes and players
	set_nexus_nodes()
	update_nexus_player(current_index)

	# enable zoom inputs
	Inputs.zoom_inputs_enabled = true

	set_process_input(false)
	await Global.get_tree().physics_frame
	await Global.get_tree().physics_frame
	set_process_input(true)

	Players.camera.position_smoothing_enabled = true
	Players.camera.force_black_screen(false)

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# ignore unrelated inputs
	if not (event.is_action(&"tab") or event.is_action(&"esc")):
		return

	Inputs.accept_event()

	if Input.is_action_just_pressed(&"tab"):
		ui.character_selector_node.show()
	elif Input.is_action_just_released(&"tab"):
		ui.character_selector_node.hide()
	elif Input.is_action_just_pressed(&"esc"):
		if ui.inventory_ui.visible:
			ui.button_focused = false
			ui.inventory_ui.hide()
			ui.options_ui.show()
		else:
			exit_nexus()

#endregion

# ..............................................................................

#region INITIALIZATION

func set_characters() -> Array[PlayerStats]:
	var party_stats: Array[PlayerStats] = []

	# get party player stats
	for player_base in Players.party_bases:
		if is_instance_valid(player_base):
			party_stats.append(player_base.stats)

	# return party player stats and standby character stats
	return party_stats + Players.standby_characters


func set_nexus_nodes() -> void:
	# set nexus nodes textures and modulate
	for index in nexus_nodes.size():
		var node_type: int = Global.nexus_types[index]

		# set texture
		nexus_nodes[index].texture.region.position = DATA.ATLAS_POSITIONS[node_type]

		# set modulate
		if node_type & DATA.NodeTypes.NULL:
			nexus_nodes[index].modulate = DATA.NULL_MODULATE
		elif node_type & DATA.NodeTypes.ALL_KEYS:
			nexus_nodes[index].modulate = DATA.KEY_MODULATE
		else:
			nexus_nodes[index].modulate = DATA.LOCKED_MODULATE

#endregion

# ..............................................................................

#region PLAYER UPDATE

func update_nexus_player(next_index: int) -> void:
	var next_stats: PlayerStats = character_stats[next_index]

	# reset unlockables outlines
	for unlockable_outline in $Unlockables.get_children():
		unlockable_outline.free()

	# for each unlocked node, reset texture and modulate
	for index in current_stats.unlocked_nodes:
		var node_type: int = Global.nexus_types[index]

		# reset texture
		nexus_nodes[index].texture.region.position = DATA.ATLAS_POSITIONS[node_type]

		# reset modulate
		if node_type & DATA.NodeTypes.NULL:
			nexus_nodes[index].modulate = DATA.NULL_MODULATE
		elif node_type & DATA.NodeTypes.ALL_KEYS:
			nexus_nodes[index].modulate = DATA.KEY_MODULATE
		else:
			nexus_nodes[index].modulate = DATA.LOCKED_MODULATE

	# update current stats and index
	current_stats = next_stats
	current_index = next_index

	# for each unlocked node, update texture and modulate
	for index in next_stats.unlocked_nodes:
		var node_type: int = Global.nexus_types[index]

		# update texture
		if node_type & DATA.NodeTypes.NULL or node_type & DATA.NodeTypes.ALL_KEYS:
			nexus_nodes[index].texture.region.position = DATA.EMPTY_ATLAS_POSITION

		# update modulate
		nexus_nodes[index].modulate = DATA.UNLOCKED_MODULATE

	# reset converted nodes array
	converted_nodes.clear()

	# for each converted node, update texture
	for converted in next_stats.converted_nodes:
		converted_nodes.append(converted.x)
		nexus_nodes[converted.x].texture.region.position = \
				DATA.EMPTY_ATLAS_POSITION if converted.y == 0 else DATA.STATS_ATLAS_POSITIONS[converted.y - 1]

	# reset unlockable nodes array
	unlockable_nodes.clear()

	# for each unlocked node, update unlockables
	for index in next_stats.unlocked_nodes:
		add_adjacent_unlockables(index)

	# update player position
	#Players.camera.position_smoothing_enabled = false
	$NexusPlayer.snap_to_position(nexus_nodes[next_stats.last_node].position + Vector2(16.0, 16.0))
	#Players.camera.reset_smoothing.call_deferred()
	#Players.camera.set_deferred(&"position_smoothing_enabled", true)

	#Players.camera.reset_smoothing()


#endregion

# ..............................................................................

#region FUNCTIONS

func get_adjacents(origin_index: int) -> Array[int]:
	var temp_adjacents: Array[int] = []
	var node_count: int = $NexusNodes.get_child_count()
	var origin_position: Vector2 = nexus_nodes[origin_index].position

	@warning_ignore("integer_division")
	var is_odd_row: bool = (origin_index / DATA.NEXUS_ROW_SIZE) % 2 == 1

	for temp_index in (DATA.NEXUS_ADJACENTS_OFFSETS[1 if is_odd_row else 0]):
		var adjusted_index: int = origin_index + temp_index

		# check if current index is within bounds
		if adjusted_index < 0 or adjusted_index >= node_count:
			continue

		# check if current node is not null
		if Global.nexus_types[adjusted_index] == DATA.NodeTypes.NULL:
			continue

		# check if current node is actually nearby
		if origin_position.distance_squared_to(nexus_nodes[adjusted_index].position) > 10000:
			continue

		temp_adjacents.append(adjusted_index)

	return temp_adjacents


func add_adjacent_unlockables(index: int) -> void:
	# for each adjacent node of index
	for adjacent in get_adjacents(index):
		# skip if adjacent is already unlocked, is in unlockables, or is null
		if (
				adjacent in current_stats.unlocked_nodes
				or adjacent in unlockable_nodes
				or nexus_nodes[adjacent].texture.region.position == DATA.NULL_ATLAS_POSITION
		):
			continue

		# for each adjacent node of adjacents
		for second_adjacent in get_adjacents(adjacent):
			# skip if second adjacent is not unlocked, is the original node, or adjacent is in unlockables
			if (
					not second_adjacent in current_stats.unlocked_nodes
					or second_adjacent == index
			):
				continue

			# if adjacent has at least 2 unlocked neighbors, add adjacent to unlockables
			unlockable_nodes.append(adjacent)

			# create unlockables outline for adjacent node
			var unlockable_instance: TextureRect = UNLOCKABLES_OUTLINE.instantiate()
			$Unlockables.add_child(unlockable_instance)
			unlockable_instance.name = StringName(str(adjacent))
			unlockable_instance.position = nexus_nodes[adjacent].position
			break


func unlock_node() -> void:
	var node_index: int = current_stats.last_node

	current_stats.unlocked_nodes.append(node_index)
	unlockable_nodes.erase(node_index)

	# remove unlockable outline
	$Unlockables.remove_child($Unlockables.get_node(NodePath(str(node_index))))

	# update node texture
	nexus_nodes[node_index].modulate = DATA.UNLOCKED_MODULATE

	# check for adjacent unlockables
	add_adjacent_unlockables(node_index)

#endregion

# ..............................................................................

#region EXIT

func exit_nexus() -> void:
	Players.camera.update_camera(Players.main_player, scene_camera_zoom)
	Players.camera.update_camera_limits(scene_camera_limits)

	Global.global_ui(Global.Ui.HOLO_NEXUS, Global.Ui.HOLO_DECK)

#endregion

# ..............................................................................
