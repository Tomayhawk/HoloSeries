extends Node

# COMBAT MANAGER

signal entering_combat
signal left_combat

# ..............................................................................

#region CONSTANTS

enum CombatState {
	NOT_IN_COMBAT,
	IN_COMBAT,
	LEAVING_COMBAT,
}

const EnemyMarker: PackedScene = preload("res://entities/entities_indicators/enemy_marker.tscn")

#endregion

# ..............................................................................

var ability_loads: Array[Resource] = [
	load("res://abilities/black_magic/fireball.tscn"),
	load("res://abilities/white_magic/regen.tscn"),
	load("res://abilities/white_magic/heal.tscn"),
	load("res://abilities/skills/play_dice.tscn"),
	load("res://abilities/talents/rocket_launcher.tscn"),
]

var locked_enemy_base: Node = null

var combat_state := CombatState.NOT_IN_COMBAT:
	set(next_state):
		if combat_state == next_state: return

		match next_state:
			CombatState.NOT_IN_COMBAT:
				left_combat.emit()
				ui.combat_ui_tween(0.0)
				$LeavingCombatTimer.stop()

				get_tree().call_group(
						&"enemies_in_combat", "remove_from_group", &"enemies_in_combat")

				unlock()
			CombatState.IN_COMBAT:
				if combat_state == CombatState.NOT_IN_COMBAT:
					entering_combat.emit()
					ui.combat_ui_tween(1.0)
				else:
					$LeavingCombatTimer.stop()
			CombatState.LEAVING_COMBAT:
				if combat_state == CombatState.IN_COMBAT:
					$LeavingCombatTimer.start(2)

		combat_state = next_state


@onready var ui: CanvasLayer = $CombatUi

# ..............................................................................

# check if in combat
func in_combat() -> bool:
	return combat_state == CombatState.IN_COMBAT


# check if leaving combat
func leaving_combat() -> bool:
	return combat_state == CombatState.LEAVING_COMBAT


# check if not in combat
func not_in_combat() -> bool:
	return combat_state == CombatState.NOT_IN_COMBAT


# enter combat
func enter_combat() -> void:
	combat_state = CombatState.IN_COMBAT


# leave combat
func leave_combat() -> void:
	combat_state = CombatState.NOT_IN_COMBAT


# remove enemy from combat
func remove_active_enemy(enemy_base: EnemyBase) -> void:
	# manage locked enemy
	if locked_enemy_base == enemy_base:
		unlock()

	# update combat state
	if get_tree().get_nodes_in_group(&"enemies_in_combat").is_empty():
		combat_state = CombatState.LEAVING_COMBAT


# lock enemy
func lock(enemy_base: EnemyBase) -> void:
	if locked_enemy_base == enemy_base: return
	unlock()
	locked_enemy_base = enemy_base
	var marker_node: Sprite2D = EnemyMarker.instantiate()
	enemy_base.add_child(marker_node)
	marker_node.position = Vector2(0, -40) # should be dynamic


# unlock enemy
func unlock() -> void:
	if locked_enemy_base == null: return
	if locked_enemy_base.has_node(^"EnemyMarker"):
		locked_enemy_base.get_node(^"EnemyMarker").queue_free()
	locked_enemy_base = null


# if node is null, checks if anything is locked
# if node is not null, checks if node is locked
func is_locked(enemy_base: EnemyBase = null) -> bool:
	return locked_enemy_base == enemy_base if enemy_base else locked_enemy_base != null


# freeing ability nodes, pick up item nodes, and/or damage display nodes
func clear_combat_entities(abilities: bool = true, lootable_items: bool = true, damage_display: bool = true) -> void:
	if abilities:
		for entity_base in Entities.abilities_node.get_children():
			entity_base.queue_free()
	if lootable_items: # TODO: should be somewhere else
		for entity_base in Entities.lootable_items_node.get_children():
			entity_base.queue_free()
	if damage_display:
		Damage.clear_damage_display()


# LEAVING_COMBAT -> NOT_IN_COMBAT
func _on_leaving_combat_timer_timeout() -> void:
	leave_combat()
