extends Node

# COMBAT (AUTOLOAD #7)

# ..............................................................................

#region SIGNALS

signal entered_combat
signal left_combat

#endregion

# ..............................................................................

#region CONSTANTS

enum CombatState {
	NOT_IN_COMBAT,
	IN_COMBAT,
	LEAVING_COMBAT,
}

const ENEMY_MARKER: PackedScene = \
		preload("res://entities/entities_indicators/enemy_marker.tscn")

#endregion

# ..............................................................................

#region VARIABLES

var locked_enemy_base: Node = null

var combat_state: CombatState = CombatState.NOT_IN_COMBAT

@onready var ui: CanvasLayer = $CombatUi

#endregion

# ..............................................................................

#region COMBAT STATES

func enter_combat() -> void:
	if combat_state == CombatState.IN_COMBAT:
		return

	if combat_state == CombatState.NOT_IN_COMBAT:
		entered_combat.emit()
		ui.combat_ui_tween(1.0)
	else: # combat_state == CombatState.LEAVING_COMBAT
		$LeavingCombatTimer.stop()

	combat_state = CombatState.IN_COMBAT


func leave_combat() -> void:
	if combat_state == CombatState.IN_COMBAT:
		$LeavingCombatTimer.start(2)
		combat_state = CombatState.LEAVING_COMBAT


func end_combat() -> void:
	if combat_state == CombatState.NOT_IN_COMBAT:
		return

	left_combat.emit()
	ui.combat_ui_tween(0.0)
	$LeavingCombatTimer.stop()

	get_tree().call_group(
			&"enemies_in_combat", "remove_from_group", &"enemies_in_combat")

	unlock()

	combat_state = CombatState.NOT_IN_COMBAT


# check if in combat
func in_combat() -> bool:
	return combat_state == CombatState.IN_COMBAT


# check if leaving combat
func leaving_combat() -> bool:
	return combat_state == CombatState.LEAVING_COMBAT


# check if not in combat
func not_in_combat() -> bool:
	return combat_state == CombatState.NOT_IN_COMBAT

#endregion

# ..............................................................................

#region LOCKED ENEMY NODE

# lock enemy
func lock(enemy_base: EnemyBase) -> void:
	if locked_enemy_base == enemy_base: return
	unlock()
	locked_enemy_base = enemy_base
	var marker_node: Sprite2D = ENEMY_MARKER.instantiate()
	enemy_base.add_child(marker_node)
	marker_node.position = Vector2(0, -40) # should be dynamic


# unlock enemy
func unlock() -> void:
	if not is_instance_valid(locked_enemy_base):
		return

	if locked_enemy_base.has_node(^"ENEMY_MARKER"):
		locked_enemy_base.get_node(^"ENEMY_MARKER").queue_free()

	locked_enemy_base = null

#endregion

# ..............................................................................

#region COMBAT ENTITIES

# remove enemy from combat
func remove_active_enemy(enemy_base: EnemyBase) -> void:
	# manage locked enemy
	if locked_enemy_base == enemy_base:
		unlock()

	# update combat state
	if get_tree().get_nodes_in_group(&"enemies_in_combat").is_empty():
		leave_combat()

#endregion

# ..............................................................................

#region SIGNALS

# LEAVING_COMBAT -> NOT_IN_COMBAT
func _on_leaving_combat_timer_timeout() -> void:
	end_combat()

#endregion

# ..............................................................................
