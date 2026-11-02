extends Node

# TEMPORARY DEVELOPMENT FILE

# ..............................................................................

#region FILE CONVERSION

func _init() -> void:
	convert_directory("user://saves/", saves_json_to_dat)
	convert_directory("res://dialogues/", dialogues_json_to_tres)


func convert_directory(dir_path: String, convert_func: Callable) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)

	dir.list_dir_begin()
	var file_name: String = dir.get_next()

	while file_name != "":
		if file_name.get_extension() == "json":
			convert_func.call(dir_path, file_name)
		file_name = dir.get_next()


func saves_json_to_dat(file_path: String, file_name: String) -> void:
	var json_path: String = file_path + file_name
	var dat_path: String = file_path + file_name.get_basename() + ".dat"

	# GUARD: .dat exists and is newer than .json -> skip
	if FileAccess.file_exists(dat_path):
		if FileAccess.get_modified_time(dat_path) > FileAccess.get_modified_time(json_path):
			return

	var data: Dictionary = \
			JSON.parse_string(FileAccess.open(json_path, FileAccess.READ).get_as_text())

	# type variables from float to int
	data["save_point"] = int(data["save_point"])
	data["last_saved"] = int(data["last_saved"])

	# type array values from float to int
	const keys: Array[String] = [
			"world_states", "consumables_inventory", "materials_inventory",
			"weapons_inventory", "armors_inventory", "accessories_inventory",
			"manager_inventory", "nexus_inventory", "keys_inventory",
			"nexus_types", "nexus_qualities", "party",
	]

	for key in keys:
		data[key] = type_int_array(data[key])

	const character_keys: Array[String] = [
			"experience", "weapon", "headgear", "chestpiece", "leggings",
			"accessory_1", "accessory_2", "accessory_3", "last_node",
	]

	for character in data["characters"]:
		# GUARD: character not unlocked -> continue to next character
		if not character:
			continue

		# type character variables from float to int
		for key in character_keys:
			character[key] = int(character[key])

		# type unlocked nodes array values from float to int
		character["unlocked_nodes"] = type_int_array(character["unlocked_nodes"])

		# type converted nodes from arrays to Vector2i
		var converted: Array[Vector2i] = []
		for value in character["converted_nodes"]:
			converted.append(Vector2i(int(value[0]), int(value[1])))
		character["converted_nodes"] = converted

	# save .dat file
	var dat_file: FileAccess = FileAccess.open(dat_path, FileAccess.WRITE)
	dat_file.store_var(data)

	print("[LOG] [dev.gd] Migrated %s -> %s" % [file_name, dat_path.get_file()])


func type_int_array(untyped_array: Array) -> Array[int]:
	var temp_array: Array[int] = []
	temp_array.assign(untyped_array)
	return temp_array


func dialogues_json_to_tres(file_path: String, file_name: String) -> void:
	var json_path: String = file_path + file_name
	var tres_path: String = file_path + file_name.get_basename() + ".tres"

	# GUARD: .tres exists and is newer than .json -> skip
	if FileAccess.file_exists(tres_path):
		if FileAccess.get_modified_time(tres_path) > FileAccess.get_modified_time(json_path):
			return

	var data: Dictionary = \
			JSON.parse_string(FileAccess.open(json_path, FileAccess.READ).get_as_text())

	var tree: DialogueTree = json_to_dialogue_tree(data)

	ResourceSaver.save(tree, tres_path)

	print("[LOG] [dev.gd] Migrated %s -> %s" % [file_name, tres_path.get_file()])


func json_to_dialogue_tree(data: Dictionary) -> DialogueTree:
	var tree := DialogueTree.new()
	var keys: Array = data.keys()
	var key_to_index: Dictionary[String, int] = {}

	for i in keys.size():
		key_to_index[keys[i]] = i

	for key in keys:
		var node_data: Dictionary = data[key]
		var node := DialogueNode.new()
		node.text.assign(node_data.get("text", []))
		node.action = StringName(node_data.get("action", ""))
		for i in node_data.get("options", []).size():
			var option := DialogueOption.new()
			option.text = node_data["options"][i]
			option.branch = key_to_index[node_data["branches"][i]]
			node.options.append(option)
		tree.nodes.append(node)

	return tree


static func dat_to_json(dat_path: String) -> void:
	var file: FileAccess = FileAccess.open(dat_path, FileAccess.READ)
	var data: Variant = bytes_to_var(file.get_buffer(file.get_length()))
	file.close()

	if not data is Dictionary:
		return
	for character in data["characters"]:
		# GUARD: character not unlocked -> continue to next character
		if not character:
			continue

		var flat_nodes: Array[Array] = []
		for vec in character["converted_nodes"]:
			flat_nodes.append([vec.x, vec.y])
		character["converted_nodes"] = flat_nodes

	var timestamp: String = Time.get_datetime_string_from_unix_time(
			data["last_saved"]).replace("T", "_").replace(":", "-")
	var json_path: String = dat_path.replace(".dat", "_%s.json" % timestamp)
	file = FileAccess.open(json_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

	print("[LOG] [dev.gd] Exported %s -> %s" % [dat_path.get_file(), json_path.get_file()])

#endregion

# ..............................................................................
