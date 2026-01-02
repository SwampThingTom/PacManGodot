class_name BonusFruitActor
extends AnimatedSprite2D
## Manages the bonus fruit for each level.

const FIRST_FRUIT_COUNT: int = 70
const SECOND_FRUIT_COUNT: int = 170
const FRUIT_AVAILABLE_SECONDS: float = 10.0
const SCORE_SHOWN_SECONDS: float = 1.0

@export var maze: MazeMap

var _level: int
var _pellets_eaten: int = 0
var _fruit_available_timer: float = 0.0
var _points_display_timer: float = 0.0


func _ready() -> void:
    position = maze.get_fruit_position()


func _process(delta: float) -> void:
    if _fruit_available_timer > 0.0:
        _fruit_available_timer -= delta
        if _fruit_available_timer <= 0.0:
            _hide_fruit()
    elif _points_display_timer > 0.0:
        _points_display_timer -= delta
        if _points_display_timer <= 0.0:
            _hide_points()


# -----------------------------------------------
# Game Lifecycle
# -----------------------------------------------

func on_start_game(blinky: GhostActor, pinky: GhostActor, inky: GhostActor, clyde: GhostActor) -> void:
    pass


func on_start_level(level: int) -> void:
    _level = level
    _pellets_eaten = 0


func on_start_round() -> void:
    _hide_fruit()
    _hide_points()


func on_playing() -> void:
    pass


func on_player_died() -> void:
    pass


func on_level_complete() -> void:
    pass


# -----------------------------------------------
# Public Methods
# -----------------------------------------------

func is_available() -> bool:
    return _fruit_available_timer > 0.0


func get_points() -> int:
    return LevelData.get_fruit_points(_level)


func on_pellet_eaten():
    _pellets_eaten += 1
    if _pellets_eaten == FIRST_FRUIT_COUNT or _pellets_eaten == SECOND_FRUIT_COUNT:
        _show_fruit()


func on_fruit_eaten():
    assert(is_available(), "Fruit eaten when not available")
    _hide_fruit()
    _show_points()


# -----------------------------------------------
# Helpers
# -----------------------------------------------

func _show_fruit() -> void:
    _fruit_available_timer = FRUIT_AVAILABLE_SECONDS
    animation = LevelData.get_fruit_name(_level)
    show()


func _hide_fruit() -> void:
    _fruit_available_timer = 0.0
    hide()


func _show_points() -> void:
    _points_display_timer = SCORE_SHOWN_SECONDS
    animation = "points_" + str(get_points())
    show()


func _hide_points() -> void:
    _points_display_timer = 0.0
    hide()
