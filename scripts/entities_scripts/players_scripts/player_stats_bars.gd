extends Resource

# ..............................................................................

#region variables

var player: PlayerBase = null
var stats: PlayerStats = null

var health_bar: ProgressBar = null
var mana_bar: ProgressBar = null
var stamina_bar: ProgressBar = null
var shield_bar: ProgressBar = null

#endregion

# ..............................................................................

#region FUNCTIONS

func set_nodes(parent_node: PlayerBase) -> void:
	player = parent_node
	stats = parent_node.stats

	health_bar = parent_node.get_node(^"HealthBar")
	mana_bar = parent_node.get_node(^"ManaBar")
	stamina_bar = parent_node.get_node(^"StaminaBar")
	shield_bar = parent_node.get_node(^"ShieldBar")

	update_health()
	update_mana()
	update_stamina()
	update_shield()

# update health bar and label
func update_health() -> void:
	var bar_percentage: float = stats.health / stats.max_health
	health_bar.value = stats.health
	health_bar.visible = stats.health > 0.0 and stats.health < stats.max_health
	health_bar.modulate = (
			Color(0, 1, 0, 1) if bar_percentage > 0.5
			else Color(1, 1, 0, 1) if bar_percentage > 0.2
			else Color(1, 0, 0, 1)
	)
	Combat.ui.health_labels[player.party_index].text = str(int(stats.health))

# update mana bar and label
func update_mana() -> void:
	mana_bar.value = stats.mana
	mana_bar.visible = stats.mana < stats.max_mana
	Combat.ui.mana_labels[player.party_index].text = str(int(stats.mana))

# update stamina bar and move state
func update_stamina() -> void:
	stamina_bar.value = stats.stamina
	stamina_bar.visible = stats.stamina < stats.max_stamina
	stamina_bar.modulate = Color(0.5, 0, 0, 1) if stats.fatigue else Color(1, 0.5, 0, 1)
	if stats.fatigue and player.move_state in [player.MoveState.DASH, player.MoveState.SPRINT]:
		player.move_state = player.MoveState.WALK
		if player.action_state in [player.ActionState.READY, player.ActionState.COOLDOWN]:
			player.update_animation()

# update shield bar
func update_shield() -> void:
	shield_bar.value = stats.shield
	shield_bar.visible = stats.shield > 0
	Combat.ui.shield_progress_bars[player.party_index].value = stats.shield
	Combat.ui.shield_progress_bars[player.party_index].modulate.a = 1.0 if stats.shield > 0 else 0.0

# update ultimate gauge bar
func update_ultimate_gauge() -> void:
	Combat.ui.ultimate_progress_bars[player.party_index].value = stats.ultimate_gauge
	Combat.ui.ultimate_progress_bars[player.party_index].modulate.g = (130.0 - stats.ultimate_gauge) / stats.max_ultimate_gauge

# update maximum bar values
func set_max_values() -> void:
	health_bar.max_value = stats.max_health
	mana_bar.max_value = stats.max_mana
	stamina_bar.max_value = stats.max_stamina
	shield_bar.max_value = stats.max_shield
	Combat.ui.ultimate_progress_bars[player.party_index].max_value = stats.max_ultimate_gauge

	update_health()
	update_mana()
	update_stamina()
	update_shield()
	update_ultimate_gauge()

#endregion

# ..............................................................................
