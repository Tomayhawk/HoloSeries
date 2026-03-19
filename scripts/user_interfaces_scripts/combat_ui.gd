extends CanvasLayer

# COMBAT UI (GLOBAL UI)

# ..............................................................................

#region CONSTANTS

const OPTIONS_BUTTON_PATH: String = \
		"res://user_interfaces/combat_ui_components/options_button.tscn"
const STANDBY_BUTTON_PATH: String = \
		"res://user_interfaces/combat_ui_components/standby_button.tscn"

const COMBAT_UI_TWEEN_DURATION: float = 0.2

#endregion

# ..............................................................................

#region INITIAL

func _ready() -> void:
	%CombatControl.modulate.a = 0.0
	%SubCombatOptions.hide()
	%CharacterSelector.hide()

	for character_infos_node in %CharacterInfosVBoxContainer.get_children():
		character_infos_node.modulate.a = 0.0

#endregion

# ..............................................................................

#region INPUTS

func _input(event: InputEvent) -> void:
	# GUARD: world inputs disabled -> ignore input
	if not Inputs.world_inputs_enabled:
		return

	# INPUT: accept events
	if event.is_action(&"display_combat_ui"):
		Inputs.accept_event()

	# GUARD: in combat -> cannot force toggle combat ui
	# INPUT: display_combat_ui -> toggle combat ui
	if event.is_action_pressed(&"display_combat_ui") and Combat.not_in_combat():
		%CombatControl.modulate.a = 1.0 if %CombatControl.modulate.a != 1.0 else 0.0
		%CombatControl.visible = %CombatControl.modulate.a == 1.0
	# INPUT: tab -> toggle character selector
	elif event.is_action(&"tab"):
		Inputs.accept_event()
		%CharacterSelector.visible = event.is_pressed()
	# GUARD: sub combat options not visible -> ignore esc input
	# INPUT: esc -> hide sub combat options
	elif event.is_action_pressed(&"esc") and %SubCombatOptions.visible:
		Inputs.accept_event()
		hide_sub_combat_options()

#endregion

# ..............................................................................

#region INVENTORY BUTTONS

func initialize_combat_inventory() -> void:
	for item_id in Inventory.consumables_inventory.size():
		if Inventory.consumables_inventory[item_id] > 0:
			add_inventory_button(item_id)


func add_inventory_button(item_id: int) -> void:
	var options_button: Button = load(OPTIONS_BUTTON_PATH).instantiate()
	var item_name: String = load(Inventory.CONSUMABLES_PATHS[item_id]).ITEM_NAME

	options_button.name = item_name
	options_button.get_node(^"Name").text = item_name
	options_button.get_node(^"Number").text = str(Inventory.consumables_inventory[item_id])
	options_button.pressed.connect(button_pressed)
	options_button.pressed.connect(use_consumable.bind(item_id))
	options_button.mouse_entered.connect(_on_control_mouse_entered)
	options_button.mouse_exited.connect(_on_control_mouse_exited)

	%ItemsGridContainer.add_child(options_button)


func remove_inventory_button(item_name: String) -> void:
	%ItemsGridContainer.get_node(NodePath(item_name)).queue_free()


func get_inventory_button(item_name: String) -> Button:
	return %ItemsGridContainer.get_node_or_null(NodePath(item_name))

#endregion

# ..............................................................................

#region STANDBY BUTTONS

func add_standby_button() -> void:
	var standby_button: Button = load(STANDBY_BUTTON_PATH).instantiate()
	%CharacterSelectorVBoxContainer.add_child(standby_button)

	# set button signals and connections
	standby_button.pressed.connect(Players.switch_standby_character.bind(standby_button.get_index()))
	standby_button.pressed.connect(button_pressed)
	standby_button.mouse_entered.connect(_on_control_mouse_entered)
	standby_button.mouse_exited.connect(_on_control_mouse_exited)

#endregion

# ..............................................................................

#region UPDATE CHARACTER UI

func update_party_ui(party_index: int, character: PlayerStats) -> void:
	var party_infos_node: Control = %CharacterInfosVBoxContainer.get_child(party_index)

	party_infos_node.get_node(^"Name").text = character.CHARACTER_NAME
	party_infos_node.get_node(^"Health").text = str(int(character.health))
	party_infos_node.get_node(^"Mana").text = str(int(character.mana))
	party_infos_node.get_node(^"Ultimate").value = character.ultimate_gauge
	party_infos_node.get_node(^"Ultimate").max_value = character.max_ultimate_gauge

	party_infos_node.modulate.a = 1.0


func hide_party_ui(party_index: int) -> void:
	%CharacterInfosVBoxContainer.get_child(party_index).modulate.a = 0.0


func update_standby_ui(standby_index: int, character: PlayerStats) -> void:
	var standby_button: Button = %CharacterSelectorVBoxContainer.get_child(standby_index)

	standby_button.get_node(^"Name").text = character.CHARACTER_NAME
	standby_button.get_node(^"Level").text = str(character.level)
	standby_button.get_node(^"Health").text = str(int(character.health))
	standby_button.get_node(^"Mana").text = str(int(character.mana))

#endregion

# ..............................................................................

#region UI TWEEN

func combat_ui_tween(target_visibility_value: float) -> void:
	%CombatControl.show()

	create_tween().tween_property(
			%CombatControl, "modulate:a", target_visibility_value,
			COMBAT_UI_TWEEN_DURATION).finished.connect(combat_ui_tween_finished)


func combat_ui_tween_finished() -> void:
	if %CombatControl.modulate.a == 0.0:
		%CombatControl.hide()

#endregion

# ..............................................................................

#region MAIN COMBAT OPTIONS

func _on_attack_pressed() -> void:
	hide_sub_combat_options()

	for button in %MainVBoxContainer.get_children():
		button.toggle_mode = false

	%MainVBoxContainer.get_child(0).toggle_mode = true
	%MainVBoxContainer.get_child(0).button_pressed = true


func _on_main_combat_options_pressed(extra_arg_0: int) -> void:
	hide_sub_combat_options()
	%SubCombatOptions.show()
	%SubModesMarginContainer.get_child(extra_arg_0).show()

	for button in %MainVBoxContainer.get_children():
		button.toggle_mode = false

	%MainVBoxContainer.get_child(extra_arg_0 + 1).toggle_mode = true
	%MainVBoxContainer.get_child(extra_arg_0 + 1).button_pressed = true

#endregion

# ..............................................................................

#region SUB COMBAT OPTIONS

func instantiate_ability(ability_index: int) -> void:
	Entities.instantiate_ability(ability_index)


func use_consumable(item_index: int) -> void:
	Inventory.use_consumable(item_index)


func hide_sub_combat_options() -> void:
	%SubCombatOptions.hide()
	for sub_mode in %SubModesMarginContainer.get_children():
		sub_mode.hide()

#endregion

# ..............................................................................

#region SIGNALS & BUTTON PRESSES

func _on_control_mouse_entered() -> void:
	Inputs.action_inputs_enabled = false
	Inputs.zoom_inputs_enabled = false


func _on_control_mouse_exited() -> void:
	Inputs.action_inputs_enabled = true
	Inputs.zoom_inputs_enabled = true


func button_pressed() -> void:
	if Entities.requesting_entities:
		Entities.end_entities_request()

#endregion

# ..............................................................................
