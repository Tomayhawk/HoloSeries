extends Area2D

# DOOM (RAORA - ULTIMATE)

# ..............................................................................

#region CONSTANTS


const RANGE: float = 100.0
const BASE_VELOCITY: Vector2 = Vector2(0.4, 0.4)
const BASE_ACCELERATION: float = 0.05
const BASE_RESISTIBILITY: float = 0.4
const BASE_DAMAGE: float = 1.0

#endregion

# ..............................................................................

#region VARIABLES

var interval: int = 10 # seconds
var increment: int = 0

#endregion

# ..............................................................................

#region INITIAL

func _ready() -> void:
    set_physics_process(false)
    pass # TODO: take from fireball

#endregion

# ..............................................................................

#region PROCESS

func _physics_process(_delta: float) -> void:
    pass

# complex DOT with damage increase on proximity within range.# constant gravity-pull physics, increase on proximity as well.
# or decrease damage interval on proximity
# this function updates velocity for entities, and deals damage to corresponding enemies.
# use a “swirl” velocity, like a torpedo
# if decreasing damage intervals, use const MIN_INTERVAL: float = 0.05
# use weight to determine final resistibility
# maybe call resistibility “force” with interaction with weight in mind.

#endregion

# ..............................................................................
