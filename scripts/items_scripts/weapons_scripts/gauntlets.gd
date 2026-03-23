extends Weapon

# GAUNTLETS (WEAPON)

# ..............................................................................

#region FUNCTIONS

static func equip(stats: PlayerStats) -> void:
    stats.strength += stats.base_strength * 0.1
    stats.defense += stats.base_defense * 0.1


static func equip_action_stats(stats: PlayerStats) -> void:
    stats.stamina_regen += 4.0
    stats.fatigue_regen += 4.0

#endregion

# ..............................................................................
