extends CanvasLayer

# ..............................................................................

#region VARIABLES

var characters: Array[PlayerStats] = []
var current_index: int = -1
var stats_label_nodes: Array[Label] = []

@onready var left_button_node: TextureButton = %LeftButton
@onready var right_button_node: TextureButton = %RightButton

#endregion

# ..............................................................................

#region READY

func _ready() -> void:
	# get party character stats
	for player in Players.get_children():
		characters.append(player.stats)

	# sort party characters by party index
	characters.sort_custom(func(a, b):
		return a.base.party_index < b.base.party_index
	)

	# get standby character stats
	for character in Players.standby_characters:
		characters.append(character)

	current_index = Players.main_player.party_index

	# set stats label nodes
	var stats_grid_container: GridContainer = %StatsMarginGridContainer
	var i: int = 0
	var label_count: int = stats_grid_container.get_child_count()
	while i < label_count:
		stats_label_nodes.append(stats_grid_container.get_child(i + 1))
		i += 2

	# update button states and stats grid
	update_button_states()
	update_characters()

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# ignore all unrelated inputs
	if not event.is_action(&"esc"):
		return

	Inputs.accept_event()

	if Input.is_action_just_pressed(&"esc"):
		exit_ui()

#endregion

# ..............................................................................

#region FUNCTIONS

func update_characters() -> void:
	var stats: PlayerStats = characters[current_index]

	stats_label_nodes[0].text = stats.CHARACTER_NAME
	stats_label_nodes[1].text = "%d" % stats.level
	stats_label_nodes[2].text = "%d / %d" % [stats.health, stats.max_health]
	stats_label_nodes[3].text = "%d / %d" % [stats.mana, stats.max_mana]
	stats_label_nodes[4].text = "%d / %d" % [stats.stamina, stats.max_stamina]
	stats_label_nodes[5].text = "%d" % stats.defense
	stats_label_nodes[6].text = "%d" % stats.ward
	stats_label_nodes[7].text = "%d" % stats.strength
	stats_label_nodes[8].text = "%d" % stats.intelligence
	stats_label_nodes[9].text = "%d" % stats.speed
	stats_label_nodes[10].text = "%d" % stats.agility
	stats_label_nodes[11].text = "%d%%" % (stats.crit_chance * 100)
	stats_label_nodes[12].text = "%d%%" % (stats.crit_damage * 100)


func update_button_states() -> void:
	var at_left_limit: bool = current_index == 0
	var at_right_limit: bool = current_index == characters.size() - 1

	left_button_node.modulate.a = 0.0 if at_left_limit else 1.0
	right_button_node.modulate.a = 0.0 if at_right_limit else 1.0

	left_button_node.disabled = at_left_limit
	right_button_node.disabled = at_right_limit


func exit_ui() -> void:
	Global.add_global_child("HoloDeck", "res://user_interfaces/holo_deck.tscn")
	queue_free()

#endregion

# ..............................................................................

#region SIGNALS

func _on_side_buttons_pressed(increment: bool) -> void:
	current_index += 1 if increment else -1

	update_button_states()
	update_characters()

#endregion

# ..............................................................................
