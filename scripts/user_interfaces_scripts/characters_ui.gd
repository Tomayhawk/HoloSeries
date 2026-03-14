extends CanvasLayer

# CHARACTERS UI (GLOBAL UI)

# ..............................................................................

#region VARIABLES

var current_index: int = -1
var character_stats: Array[PlayerStats] = []
var stats_label_nodes: Array[Label] = []

@onready var left_button_node: TextureButton = %LeftButton
@onready var right_button_node: TextureButton = %RightButton

#endregion

# ..............................................................................

#region INITIAL

func _ready() -> void:
	current_index = Players.main_player.party_index

	# get party player stats
	for player_base in Players.party_bases:
		if is_instance_valid(player_base):
			character_stats.append(player_base.stats)

	# get standby character stats
	character_stats.append_array(Players.standby_characters)

	# set stats label nodes
	var stats_grid_container: GridContainer = %StatsMarginGridContainer
	for i in range(1, stats_grid_container.get_child_count(), 2):
		stats_label_nodes.append(stats_grid_container.get_child(i))

	# update button states and stats grid
	update_character_stats()
	update_button_states()

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# INPUT: accept events
	if event.is_action(&"esc"):
		Inputs.accept_event()

	# INPUT: esc -> exit ui
	if event.is_action_pressed(&"esc"):
		exit_ui()

#endregion

# ..............................................................................

#region FUNCTIONS

func update_character_stats() -> void:
	var stats: PlayerStats = character_stats[current_index]

	stats_label_nodes[0].text = stats.CHARACTER_NAME
	stats_label_nodes[1].text = "%d" % stats.level
	stats_label_nodes[2].text = "%d / %d" % [stats.experience, stats.experience_required]
	stats_label_nodes[3].text = "%d / %d" % [stats.health, stats.max_health]
	stats_label_nodes[4].text = "%d / %d" % [stats.mana, stats.max_mana]
	stats_label_nodes[5].text = "%d / %d" % [stats.stamina, stats.max_stamina]
	stats_label_nodes[6].text = "%d" % stats.defense
	stats_label_nodes[7].text = "%d" % stats.ward
	stats_label_nodes[8].text = "%d" % stats.strength
	stats_label_nodes[9].text = "%d" % stats.intelligence
	stats_label_nodes[10].text = "%d" % stats.speed
	stats_label_nodes[11].text = "%d" % stats.agility
	stats_label_nodes[12].text = "%d%%" % (stats.crit_chance * 100.0)
	stats_label_nodes[13].text = "%d%%" % (stats.crit_damage * 100.0)


func update_button_states() -> void:
	var at_left_limit: bool = current_index == 0
	var at_right_limit: bool = current_index == character_stats.size() - 1

	left_button_node.modulate.a = 0.0 if at_left_limit else 1.0
	right_button_node.modulate.a = 0.0 if at_right_limit else 1.0

	left_button_node.disabled = at_left_limit
	right_button_node.disabled = at_right_limit


func exit_ui() -> void:
	Global.global_ui(Global.Ui.CHARACTERS, Global.Ui.HOLO_DECK)

#endregion

# ..............................................................................

#region SIGNALS

func _on_side_buttons_pressed(increment: bool) -> void:
	current_index += 1 if increment else -1
	update_character_stats()
	update_button_states()

#endregion

# ..............................................................................
