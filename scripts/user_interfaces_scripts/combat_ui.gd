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

#region VARIABLES

var focused_main_option: Button = null
var focused_sub_option: Button = null

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

	# INPUT: display_combat_ui -> toggle combat ui
	if event.is_action(&"display_combat_ui"):
		Inputs.accept_event()
		if not event.is_pressed():
			return
		if %SubCombatOptions.visible:
			%SubCombatOptions.hide()
		elif Combat.not_in_combat():
			%CombatControl.modulate.a = 1.0 if %CombatControl.modulate.a != 1.0 else 0.0
			%CombatControl.visible = %CombatControl.modulate.a == 1.0
		else:
			%SubCombatOptions.show()

	# INPUT: tab -> toggle character selector
	elif event.is_action(&"tab"):
		Inputs.accept_event()
		%CharacterSelector.visible = event.is_pressed()

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
	options_button.pressed.connect(_on_combat_button_pressed)
	options_button.pressed.connect(_on_consumable_button_pressed.bind(options_button, item_id))
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
	standby_button.pressed.connect(_on_combat_button_pressed)
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

#region FOCUSED BUTTONS

func set_focused_options(next_main_option: Button, next_sub_option: Button) -> void:
	if not next_main_option:
		reset_focused_main_option()
		%SubCombatOptions.hide()
		return

	set_focused_main_option(next_main_option)
	scroll_to_button(%MainScrollContainer, next_main_option)

	if not is_instance_valid(next_sub_option):
		reset_focused_sub_option()
		%SubCombatOptions.hide()
		return

	for sub_mode in %SubModesMarginContainer.get_children():
		sub_mode.hide()

	next_sub_option.get_parent().show()
	%SubCombatOptions.show()

	set_focused_sub_option(next_sub_option)
	scroll_to_button(%SubScrollContainer, next_sub_option)


func scroll_to_button(scroll: ScrollContainer, button: Button) -> void:
	var button_top: float = button.position.y
	var button_bottom: float = button.position.y + button.size.y
	var scroll_top: float = scroll.scroll_vertical
	var scroll_bottom: float = scroll_top + scroll.size.y

	if button_top < scroll_top:
		scroll.scroll_vertical = int(button_top)
	elif button_bottom > scroll_bottom:
		scroll.scroll_vertical = int(button_bottom - scroll.size.y)


func reset_focused_main_option() -> void:
	if is_instance_valid(focused_main_option):
		focused_main_option.toggle_mode = false

	focused_main_option = null


func set_focused_main_option(next_button: Button) -> void:
	reset_focused_main_option()

	focused_main_option = next_button
	focused_main_option.toggle_mode = true
	focused_main_option.button_pressed = true


func reset_focused_sub_option() -> void:
	if is_instance_valid(focused_sub_option):
		focused_sub_option.toggle_mode = false

	focused_sub_option = null


func set_focused_sub_option(next_button: Button) -> void:
	reset_focused_sub_option()

	focused_sub_option = next_button
	focused_sub_option.toggle_mode = true
	focused_sub_option.button_pressed = true

#endregion

# ..............................................................................

#region UI TWEEN

func combat_ui_tween(target_visibility_value: float) -> void:
	%CombatControl.show()

	create_tween().tween_property(
			%CombatControl, "modulate:a", target_visibility_value,
			COMBAT_UI_TWEEN_DURATION).finished.connect(_on_combat_ui_tween_finished)


func _on_combat_ui_tween_finished() -> void:
	if %CombatControl.modulate.a == 0.0:
		%CombatControl.hide()

#endregion

# ..............................................................................

#region MAIN COMBAT OPTIONS

func _on_attack_pressed() -> void:
	%SubCombatOptions.hide()
	set_focused_main_option(%MainVBoxContainer.get_child(0))


func _on_main_combat_options_pressed(extra_arg_0: int) -> void:
	set_focused_main_option(%MainVBoxContainer.get_child(extra_arg_0 + 1))

	for sub_mode in %SubModesMarginContainer.get_children():
		sub_mode.hide()

	%SubModesMarginContainer.get_child(extra_arg_0).show()
	%SubCombatOptions.show()

	reset_focused_sub_option()

#endregion

# ..............................................................................

#region SUB COMBAT OPTIONS

func _on_ability_button_pressed(source: Button, ability_index: int) -> void:
	set_focused_sub_option(source)
	Entities.instantiate_ability(ability_index)


func _on_consumable_button_pressed(source: Button, item_index: int) -> void:
	set_focused_sub_option(source)
	Inventory.use_consumable(item_index)

#endregion

# ..............................................................................

#region SIGNALS

func _on_control_mouse_entered() -> void:
	Inputs.action_inputs_enabled = false
	Inputs.zoom_inputs_enabled = false


func _on_control_mouse_exited() -> void:
	Inputs.action_inputs_enabled = true
	Inputs.zoom_inputs_enabled = true


func _on_combat_button_pressed() -> void:
	if Entities.requesting_entities:
		Entities.end_entities_request()

#endregion

# ..............................................................................
