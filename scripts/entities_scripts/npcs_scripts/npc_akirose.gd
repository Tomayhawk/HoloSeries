extends AnimatedSprite2D

# ..............................................................................

#region CONSTANTS

enum NpcState {
	NEVER_SPOKEN,
	REGULAR,
	SHOP_OPEN,
	SHOP_CLOSED,
	CAN_RECRUIT,
}

const DIALOGUE_PATH: String = "res://dialogues/akirose.json"

#endregion

# ..............................................................................

#region VARIABLES

var npc_state: NpcState = NpcState.CAN_RECRUIT

#endregion

# ..............................................................................

#region DIALOGUE

func initiate_dialogue() -> void:
	TextBox.npc_dialogue(self, DIALOGUE_PATH)
	'''
	match npc_state:
		NpcState.NEVER_SPOKEN:
			default_dialogue()
		NpcState.SHOP_OPEN:
			pass
		NpcState.SHOP_CLOSED:
			pass
		NpcState.CAN_RECRUIT:
			default_dialogue()
		_:
			default_dialogue()
	'''


func default_dialogue():
	var resp_index := 0
	var responses := []

	resp_index = await TextBox.option_selected
	responses = [
		[["Thank You!", "I will join your party."], []],
		[["But Why"], ["Potato Salad", "French Fries"]],
		[["????"], []],
	]

	TextBox.npc_dialogue(responses[resp_index][0], responses[resp_index][1])

	if resp_index == 1:
		resp_index = await TextBox.option_selected
		responses = [
			[["Thank You!", "I will join your party."], []],
			[[], []],
		] # TODO: want textbox fade out animation

		TextBox.npc_dialogue(responses[resp_index][0], responses[resp_index][1])

	# end dialogue if not recruiting
	if resp_index == 0:
		recruit_character()
		queue_free()

#endregion

# ..............................................................................

#region RECRUIT

const AKIROSE_PATH: String = "res://entities/character_animations/akirose.tres"
const PLAYER_PATH: String = "res://entities/player_base.tscn"

func recruit_character() -> void:
	var stats: EntityStats = load(AKIROSE_PATH).instantiate()
	if Players.get_child_count() < 4 and Players.standby_characters.is_empty():
		var base: PlayerBase = load(PLAYER_PATH).instantiate()
		Players.add_child(base)
		base.stats = stats
		stats.base = base

		stats.node_index = Players.get_child_count() - 1 # TODO
		base.position = Players.main_player.position + (25 * Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)))

		# TODO: make function for this
		Combat.ui.character_name_label_nodes[stats.node_index].text = stats.CHARACTER_NAME
		Combat.ui.players_info_nodes[stats.node_index].show()
		Combat.ui.ultimate_progress_bar_nodes[stats.node_index].show()
		Combat.ui.shield_progress_bar_nodes[stats.node_index].show()
	else:
		Players.standby_node.add_child(stats)
		stats.node_index = stats.get_index()

	stats.level = 1
	stats.base_health = stats.CHARACTER_HEALTH
	stats.base_mana = stats.CHARACTER_MANA
	stats.base_stamina = stats.CHARACTER_STAMINA

	stats.base_defense = stats.CHARACTER_DEFENSE
	stats.base_ward = stats.CHARACTER_WARD
	stats.base_strength = stats.CHARACTER_STRENGTH
	stats.base_intelligence = stats.CHARACTER_INTELLIGENCE
	stats.base_speed = stats.CHARACTER_SPEED
	stats.base_agility = stats.CHARACTER_AGILITY
	stats.base_crit_chance = stats.CHARACTER_CRIT_CHANCE
	stats.base_crit_damage = stats.CHARACTER_CRIT_DAMAGE

	stats.last_node = 522
	stats.unlocked_nodes = stats.CHARACTER_DEFAULT_UNLOCKED
	Global.nexus_converted_nodes[3] = []

	var standby_button: Button = load("res://user_interfaces/user_interfaces_resources/combat_ui/standby_button.tscn").instantiate()
	Combat.ui.get_node(^"CharacterSelector/MarginContainer/ScrollContainer/CharacterSelectorVBoxContainer").add_child(standby_button)
	standby_button.pressed.connect(Players.switch_standby_character.bind(standby_button.get_index()))
	standby_button.pressed.connect(Combat.ui.button_pressed)
	standby_button.mouse_entered.connect(Combat.ui._on_control_mouse_entered)
	standby_button.mouse_exited.connect(Combat.ui._on_control_mouse_exited)

	Combat.ui.standby_name_labels.append(standby_button.get_node(^"Name"))
	Combat.ui.standby_level_labels.append(standby_button.get_node(^"Level"))
	Combat.ui.standby_health_labels.append(standby_button.get_node(^"HealthAmount"))
	Combat.ui.standby_mana_labels.append(standby_button.get_node(^"ManaAmount"))

	# TODO: nexus

	stats.update_nodes()

	if stats.node_index == -1:
		Combat.ui.update_character_selector()

func end_dialogue() -> void:
	pass

#endregion

# ..............................................................................
