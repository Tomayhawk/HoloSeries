extends Node

# DAMAGE (AUTOLOAD #6)

# ..............................................................................

#region CONSTANTS

enum DamageTypes {
	# target
    PLAYER_TARGET = 0,
    ENEMY_TARGET = 1 << 1,

	# basic types
    PHYSICAL = 1 << 2,
    MAGIC = 1 << 3,
    LIGHT = 1 << 4,
    DARK = 1 << 5,
    PIERCING = 1 << 6,
	HEAL = 1 << 7,

	# modifiers
	NO_MISS = 1 << 8,
	NO_CRITICAL = 1 << 9,
	NO_RANDOM = 1 << 10,
    NO_LETHAL = 1 << 11,
    NO_REFLECT = 1 << 12,
    NO_COUNTER = 1 << 13,

	# special
    MISS = 1 << 14,
	CRITICAL = 1 << 15,
	BREAK_LIMIT = 1 << 16,
    HIDDEN = 1 << 17,
}

const MISS_MAX: float = 0.25
const MISS_BASE: float = 0.075
const MISS_SCALE: float = (MISS_MAX - MISS_BASE) / 50.0

const RANDOM_RANGE: Vector2 = Vector2(0.97, 1.03)

const MAX_DAMAGE: float = 9999.0
const MAX_DAMAGE_BREAK_LIMIT: float = 99999.0

const DAMAGE_DISPLAY_FONT: Font = preload("res://visuals/fonts/SHPinscher-Regular.otf")

#endregion

# ..............................................................................

#region CALCULATIONS

func combat_damage(damage: float, types: int, origin: EntityStats, target: EntityStats) -> float:
	# attempt miss
	if not types & DamageTypes.NO_MISS:
		types |= attempt_miss(types, origin, target)

	# handle miss
	if types & DamageTypes.MISS:
		damage_display(0, target.base.position, types)
		return 0.0

	# attempt crit
	if not types & DamageTypes.NO_CRITICAL:
		types |= DamageTypes.CRITICAL if randf() < origin.crit_chance else 0

	# damage calculation
	if types & DamageTypes.HEAL:
		damage = calculate_heal(damage, origin)
	else:
		damage = calculate_damage(damage, types, origin, target)

	# update target
	target.update_health(damage)

	# display damage
	damage_display(abs(damage), target.base.position, types)

	return damage


func attempt_miss(types: int, origin: EntityStats, target: EntityStats) -> int:
	# GUARD: target has invincibility -> MISS
	if target.has_status(Entities.Status.INVINCIBLE):
		return DamageTypes.MISS

	var miss_chance: float = \
			MISS_BASE + (target.agility - origin.speed) * MISS_SCALE

	# 1.5 times miss chance for physical attacks
	if types & DamageTypes.PHYSICAL:
		miss_chance *= 1.5

	var will_miss: bool = randf() < minf(miss_chance, MISS_MAX)

	return DamageTypes.MISS if will_miss else 0


func calculate_heal(amount: float, origin: EntityStats) -> float:
	# TODO: INCOMPLETE
	return amount * (1 + (origin.intelligence * 0.05))


func calculate_damage(damage: float, types: int, origin: EntityStats, target: EntityStats) -> float:
	# TODO: INCOMPLETE AND UGLY
	if types & DamageTypes.PHYSICAL: # physical damage
		damage += (origin.strength * 2) + (damage * origin.strength * 0.05)
		damage *= origin.level / (target.level + (origin.level * (1 + (target.defense * 1.0 / 1500))))
	elif types & DamageTypes.MAGIC: # magic damage
		damage += (origin.intelligence * 2) + (damage * origin.intelligence * 0.05)
		damage *= origin.level / (target.level + (origin.level * (1 + (target.ward * 1.0 / 1500))))
	if types & DamageTypes.PLAYER_TARGET:
		damage += (damage * (0.7 - (((target.defense - 1000) * (target.defense - 1000)) * 1.0 / 1425000))) + (target.defense * 1.0 / 3)

	return apply_modifiers(damage, types, origin, target)


func apply_modifiers(damage: float, types: int, origin: EntityStats, target: EntityStats) -> float:
	# handle crit
	if types & DamageTypes.CRITICAL:
		damage *= origin.crit_damage

	# handle random
	if not types & DamageTypes.NO_RANDOM:
		damage *= randf_range(RANDOM_RANGE.x, RANDOM_RANGE.y)

	# clamp damage
	if types & DamageTypes.BREAK_LIMIT:
		damage = minf(damage, MAX_DAMAGE_BREAK_LIMIT)
	else:
		damage = minf(damage, MAX_DAMAGE)

	# handle non-lethal
	if types & DamageTypes.NO_LETHAL:
		damage = minf(damage, maxf(target.health - 1.0, 0.0))

	# change sign
	damage = -damage

	return damage

#endregion

# ..............................................................................

#region DAMAGE DISPLAY

func damage_display(damage: int, display_position: Vector2, types: int) -> void:
	if types & DamageTypes.HIDDEN:
		return

	var display = Label.new()
	display.text = str(damage)
	display.z_index = 5
	add_child(display)

	# set display color
	var color: String = "#FFF"
	if types & DamageTypes.MISS:
		display.text = "Miss"
		color = "#FFF8"
	elif types & DamageTypes.HEAL:
		color = "#3E3"
	elif types & DamageTypes.CRITICAL:
		color = "#FB0"
	elif types & DamageTypes.PLAYER_TARGET:
		color = "#B22"

	display.set(&"theme_override_colors/font_color", color)
	display.set(&"theme_override_fonts/font", DAMAGE_DISPLAY_FONT)
	display.set(&"theme_override_font_sizes/font_size", 20) # TODO: should scale on damage 20 to 28
	display.set(&"theme_override_colors/font_outline_color", "#000")
	display.set(&"theme_override_constants/outline_size", 2)

	display.position = display_position + Vector2(0, -5) - Vector2(display.size / 2) + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	display.pivot_offset = Vector2(display.size / 2)

	var tween = display.create_tween()

	tween.set_parallel(true)
	tween.tween_property(display, "position:y", display.position.y - 24, 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(display, "position:y", display.position.y - 16, 0.25).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(display, "scale", Vector2(0.75, 0.75), 0.25).set_ease(Tween.EASE_IN).set_delay(0.25)

	tween.finished.connect(display.queue_free)


func clear_damage_displays() -> void:
	for display in get_children():
		display.queue_free()

#endregion

# ..............................................................................
