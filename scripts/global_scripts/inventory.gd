extends Node

# INVENTORY (AUTOLOAD #8)

# ..............................................................................

#region CONSTANTS

enum ItemTypes {
	CONSUMABLES,
	MATERIALS,
	WEAPONS,
	ARMORS,
	ACCESSORIES,
	MANAGER,
	NEXUS,
	KEY,
}

enum LootablesKeys {
	TEMP_SHIRAKAMI,
}

const CONSUMABLES_PATHS: Array[String] = [
	"res://scripts/items_scripts/consumables_scripts/potion.gd",
	"res://scripts/items_scripts/consumables_scripts/max_potion.gd",
	"res://scripts/items_scripts/consumables_scripts/phoenix_burger.gd",
	"res://scripts/items_scripts/consumables_scripts/reset_button.gd",
	"res://scripts/items_scripts/consumables_scripts/temp_kill_item.gd",
]

const WEAPON_PATHS: Array[String] = []
const ARMOR_PATHS: Array[String] = []
const ACCESSORY_PATHS: Array[String] = []

const LOOTABLES: Dictionary[LootablesKeys, Array] = {
	LootablesKeys.TEMP_SHIRAKAMI: [
		&"res://visuals/temporary/temp_shirakami.png", ItemTypes.CONSUMABLES, 0
	],
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
var manager_inventory: Array[int] = []
var nexus_inventory: Array[int] = []
var keys_inventory: Array[int] = []

#endregion

# ..............................................................................

#region FUNCTIONS

func add_item(type: ItemTypes, id: int, count: int = 1) -> void:
	match type:
		ItemTypes.CONSUMABLES: consumables_inventory[id] += count
		ItemTypes.MATERIALS: materials_inventory[id] += count
		ItemTypes.WEAPONS: weapons_inventory[id] += count
		ItemTypes.ARMORS: armors_inventory[id] += count
		ItemTypes.ACCESSORIES: accessories_inventory[id] += count
		ItemTypes.MANAGER: manager_inventory[id] += count
		ItemTypes.NEXUS: nexus_inventory[id] += count
		ItemTypes.KEY: keys_inventory[id] += count

	# add combat inventory button for new consumables
	if type == ItemTypes.CONSUMABLES and consumables_inventory[id] == count:
		Combat.ui.add_inventory_button(id)


func use_consumable(id: int, target_entities: Array[EntityBase] = []) -> void:
	var item: Resource = load(CONSUMABLES_PATHS[id])
	var request_count: int = item.REQUEST_COUNT
	var single_target: bool = request_count == 1

	if not request_count:
		item.use_item(id)
	# ally requests
	elif request_count == target_entities.size():
		if single_target:
			item.use_item(target_entities[0], id)
		else:
			item.use_item(target_entities, id)
	# main player requests
	else:
		if single_target:
			Entities.entity_request_ended.connect(item.use_item.bind(id), CONNECT_ONE_SHOT)
		else:
			Entities.entities_request_ended.connect(item.use_item.bind(id), CONNECT_ONE_SHOT)

		Entities.request_entities(item.REQUEST_TYPES, item.auto_request, request_count)


func decrement_consumable(id: int) -> void:
	var options_button: Button = \
			Combat.ui.get_inventory_button(load(CONSUMABLES_PATHS[id]).ITEM_NAME)

	consumables_inventory[id] -= 1

	if consumables_inventory[id] <= 0:
		if options_button:
			options_button.queue_free()
	else:
		options_button.get_node(^"Number").text = str(consumables_inventory[id])


#endregion

# ..............................................................................
