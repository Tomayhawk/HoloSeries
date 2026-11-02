class_name EnemyStats
extends EntityStats

# ..............................................................................

#region SET STATS

func set_enemy_base_stats(set_stats: Dictionary[StringName, float]) -> void:
    for stat_name in set_stats.keys():
        set(stat_name, set_stats[stat_name])

#endregion

# ..............................................................................
