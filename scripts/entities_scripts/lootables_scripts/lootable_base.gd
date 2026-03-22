extends Area2D

# LOOTABLE BASE (LOOTABLE)

# ..............................................................................

#region VARIABLES

var item_type: Inventory.ItemTypes = Inventory.ItemTypes.CONSUMABLES
var item_id: int = -1

var nearby_players: Array[PlayerBase] = []
var target_player: PlayerBase = null
var multiplier: float = 1.0
var increment: float = 0.1

#endregion

# ..............................................................................

#region INITIAL

func _ready() -> void:
	set_physics_process(false)

#endregion

# ..............................................................................

#region PROCESS

func _physics_process(_delta: float) -> void:
	global_position += (target_player.global_position - global_position).normalized() * multiplier
	multiplier = minf(multiplier + increment, 10.0)

#endregion

# ..............................................................................

#region FUNCTIONS

func instantiate_item(base_position: Vector2, texture_path: StringName, type: Inventory.ItemTypes, id: int) -> void:
	global_position = base_position + Vector2(15 * randf_range(-1.0, 1.0), 15 * randf_range(-1.0, 1.0))
	Entities.get_node(^"Lootables").add_child(self)
	$Sprite2D.texture = load(texture_path)
	item_type = type
	item_id = id


func player_entered(player_base: PlayerBase) -> void:
	if not nearby_players.has(player_base):
		nearby_players.append(player_base)

	if not target_player:
		target_player = player_base
		set_physics_process(true)


func player_exited(player_base: PlayerBase) -> void:
	nearby_players.erase(player_base)

	if nearby_players.is_empty():
		set_physics_process(false)
		target_player = null
		multiplier = 1.0
	else:
		var least_distance: float = INF
		for nearby_player in nearby_players:
			var temp_distance: float = global_position.distance_squared_to(target_player.global_position)
			if temp_distance < least_distance:
				target_player = nearby_player
				least_distance = temp_distance

#endregion

# ..............................................................................

#region SIGNALS

func _on_body_entered(_body: PlayerBase) -> void:
	Inventory.add_item(item_type, item_id)
	queue_free()

#endregion

# ..............................................................................
