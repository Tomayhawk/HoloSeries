extends Node2D

# HOLONEXUS

# ..............................................................................

#region CONSTANTS

const DATA: RefCounted = preload("res://scripts/holo_nexus_scripts/nexus_data.gd")

const CAMERA_LIMITS: Array[int] = [-679, -592, 681, 592]

const UNLOCKABLES_OUTLINE_PATH: String = \
		"res://holo_nexus/nexus_components/nexus_unlockables_outline.tscn"

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
@onready var nexus_nodes: Array[Node] = $NexusNodes.get_children()

#endregion

# ..............................................................................

#region INITIAL

func _init() -> void:
	Players.camera.force_black_screen(true)
	Players.camera.position_smoothing_enabled = false


func _ready() -> void:
	# update camera
	Players.camera.update_camera($NexusPlayer, Vector2(1.0, 1.0))
	Players.camera.update_camera_limits(CAMERA_LIMITS)
	set_process_input(false)

	# initialize nodes and players
	reset_nexus_textures()
	update_nexus_player(current_index)

	# enable zoom inputs
	Inputs.zoom_inputs_enabled = true

	await Global.get_tree().physics_frame
	await Global.get_tree().physics_frame

	# update camera
	Players.camera.position_smoothing_enabled = true
	Players.camera.force_black_screen(false)
	set_process_input(true)

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# INPUT: esc -> exit nexus
	if event.is_action(&"esc"):
		Inputs.accept_event()
		if event.is_pressed():
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


func reset_nexus_textures(all: bool = true) -> void:
	# set nexus nodes textures and modulate
	for index in range(DATA.NEXUS_NODES_COUNT) if all else current_stats.unlocked_nodes:
		var node_type: int = Global.nexus_types[index]

		# set texture
		nexus_nodes[index].texture.region.position = DATA.ATLAS_POSITIONS[node_type]

		# set modulate
		if node_type & DATA.NodeTypes.NULL:
			nexus_nodes[index].self_modulate = DATA.NULL_MODULATE
		elif node_type & DATA.NodeTypes.ALL_KEYS:
			nexus_nodes[index].self_modulate = DATA.KEY_MODULATE
		else:
			nexus_nodes[index].self_modulate = DATA.LOCKED_MODULATE

#endregion

# ..............................................................................

#region PLAYER UPDATE

func update_nexus_player(next_index: int) -> void:
	var next_stats: PlayerStats = character_stats[next_index]

	# reset unlockables outlines
	get_tree().call_group(&"unlockables_outline", &"queue_free")

	# reset textures and modulates
	reset_nexus_textures(false)

	# update current stats and index
	current_stats = next_stats
	current_index = next_index

	# for each unlocked node, update texture and modulate
	for node_index in next_stats.unlocked_nodes:
		var node_type: int = Global.nexus_types[node_index]

		# update texture
		if node_type & DATA.NodeTypes.NULL or node_type & DATA.NodeTypes.ALL_KEYS:
			nexus_nodes[node_index].texture.region.position = DATA.ATLAS_POSITIONS[DATA.NodeTypes.EMPTY]

		# update modulate
		nexus_nodes[node_index].self_modulate = DATA.UNLOCKED_MODULATE

	# reset converted nodes array
	converted_nodes.clear()

	# for each converted node, update texture
	for converted in next_stats.converted_nodes:
		converted_nodes.append(converted.x)
		nexus_nodes[converted.x].texture.region.position = DATA.ATLAS_POSITIONS[converted.y]

	# reset unlockable nodes array
	unlockable_nodes.clear()

	# for each unlocked node, update unlockables
	for node_index in next_stats.unlocked_nodes:
		add_adjacent_unlockables(node_index)

	# update player position
	$NexusPlayer.snap_to_position(nexus_nodes[next_stats.last_node].position + $NexusPlayer.POSITION_OFFSET)

#endregion

# ..............................................................................

#region FUNCTIONS

func get_adjacents(origin_index: int) -> Array[int]:
	var temp_adjacents: Array[int] = []

	@warning_ignore("integer_division")
	var is_odd_row: bool = (origin_index / DATA.NEXUS_ROW_SIZE) % 2 == 1
	var origin_col: int = origin_index % DATA.NEXUS_ROW_SIZE

	for index_offset in (DATA.NEXUS_ADJACENTS_OFFSETS[1 if is_odd_row else 0]):
		var adjacent_index: int = origin_index + index_offset
		var adjacent_col: int = adjacent_index % DATA.NEXUS_ROW_SIZE
		# GUARD: node index is out of bounds || node wraps row || node is null type -> skip
		if (
				adjacent_index >= 0 and adjacent_index < DATA.NEXUS_NODES_COUNT
				and absi(adjacent_col - origin_col) <= 1
				and Global.nexus_types[adjacent_index] != DATA.NodeTypes.NULL
		):
			temp_adjacents.append(adjacent_index)

	return temp_adjacents


func add_adjacent_unlockables(index: int) -> void:
	# for each adjacent node of index
	for adjacent in get_adjacents(index):
		# GUARD: node is unlocked || node is already in unlockables -> skip
		if adjacent in current_stats.unlocked_nodes or adjacent in unlockable_nodes:
			continue

		# for each adjacent node of adjacents
		for second_adjacent in get_adjacents(adjacent):
			# GUARD: node is unlocked || node is the original node -> skip
			if not second_adjacent in current_stats.unlocked_nodes or second_adjacent == index:
				continue

			# if adjacent has at least 2 unlocked neighbors, add adjacent to unlockables
			unlockable_nodes.append(adjacent)

			# create unlockables outline for adjacent node
			nexus_nodes[adjacent].add_child(load(UNLOCKABLES_OUTLINE_PATH).instantiate())

			break


func unlock_node() -> void:
	var node_index: int = current_stats.last_node

	current_stats.unlocked_nodes.append(node_index)
	unlockable_nodes.erase(node_index)

	# remove unlockable outline
	nexus_nodes[node_index].get_child(0).queue_free()

	# update node texture
	nexus_nodes[node_index].self_modulate = DATA.UNLOCKED_MODULATE

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
