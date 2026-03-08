extends Node

# INVENTORY (AUTOLOAD #8)

# ..............................................................................

#region CONSTANTS

enum LootablesKeys {
	TEMP_SHIRAKAMI,
}

const LOOTABLES: Dictionary[LootablesKeys, Array] = {
	LootablesKeys.TEMP_SHIRAKAMI: [&"res://visuals/temporary/temp_shirakami.png", 0, 0],
}

#endregion

# ..............................................................................

#region VARIABLES

# inventories
var consumables_inventory: Array[int] = []
var materials_inventory: Array[int] = []
var weapons_inventory: Array[int] = []
var armors_inventory: Array[int] = []
var accessories_inventory: Array[int] = []
var nexus_inventory: Array[int] = []
var key_inventory: Array[int] = []

var consumables: Array[Resource] = [
	load("res://scripts/items_scripts/consumables_scripts/potion.gd"),
	load("res://scripts/items_scripts/consumables_scripts/max_potion.gd"),
	load("res://scripts/items_scripts/consumables_scripts/phoenix_burger.gd"),
	load("res://scripts/items_scripts/consumables_scripts/reset_button.gd"),
	load("res://scripts/items_scripts/consumables_scripts/temp_kill_item.gd"),
]
var weapons: Array[Weapon] = []
var armors: Array[Armor] = []
var accessories: Array[Accessory] = []

#endregion

# ..............................................................................

#region FUNCTIONS

func add_item(item_type: int, item_id: int, count: int = 1) -> void:
	match item_type:
		0: consumables_inventory[item_id] += count
		1: materials_inventory[item_id] += count
		2: weapons_inventory[item_id] += count
		3: armors_inventory[item_id] += count
		4: accessories_inventory[item_id] += count
		5: nexus_inventory[item_id] += count
		6: key_inventory[item_id] += count

	if item_type == 0:
		if consumables_inventory[item_id] == 1:
			pass # TODO: create a combat button
		else:
			pass # TODO: modify combat button


func use_consumable(index: int, is_main_player: bool = true) -> void: # TODO
	if is_main_player and Entities.requesting_entities:
		return

	var item: Consumable = consumables[index].new()
	var combat_ui_button_node: Button = Combat.ui.items_grid_container_node.get_node_or_null(item.ITEM_NAME)

	if consumables_inventory[index] <= 0:
		if combat_ui_button_node:
			combat_ui_button_node.queue_free()
		return

	var request_count = item.REQUEST_COUNT

	# TODO: bad code
	if not request_count:
		item.use_item()
	elif request_count == 1:
		var chosen_node: EntityBase = null

		if is_main_player:
			Entities.request_entities(item.request_types, request_count)
			chosen_node = await Entities.entity_request_ended
		else:
			chosen_node = Entities.ally_request_entities()

		if not chosen_node:
			return

		item.use_item(chosen_node)

	else:
		var chosen_nodes: Array[EntityBase] = []

		if is_main_player:
			Entities.request_entities(item.request_types, request_count)
			chosen_nodes = await Entities.entities_request_ended
		else:
			chosen_nodes = Entities.ally_request_entities()

		if chosen_nodes.size() != request_count:
			return

		item.use_item(chosen_nodes)

	consumables_inventory[index] -= 1

	if consumables_inventory[index] == 0:
		if combat_ui_button_node:
			combat_ui_button_node.queue_free()
	else:
		combat_ui_button_node.get_node(^"Number").text = str(consumables_inventory[index])


func change_weapon(_character: Node, _index: int) -> void:
	pass


func change_armor(_character: Node, _index: int) -> void:
	pass


func change_accessories(_character: Node, _index: int) -> void:
	pass

#endregion

# ..............................................................................
