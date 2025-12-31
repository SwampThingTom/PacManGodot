class_name Fruit
extends AnimatedSprite2D
## Manages the bonus fruit for each level.

const FIRST_FRUIT_COUNT: int = 70
const SECOND_FRUIT_COUNT: int = 170
const FRUIT_AVAILABLE_SECONDS: float = 10.0
const SCORE_SHOWN_SECONDS: float = 1.0

@export var maze: Maze

var _points: int
var _pellets_eaten: int = 0
var _fruit_available_timer: float = 0.0
var _score_display_timer: float = 0.0


func _ready() -> void:
    position = maze.get_fruit_position()


func _process(delta: float) -> void:
    if _fruit_available_timer > 0.0:
        _fruit_available_timer -= delta
        if _fruit_available_timer <= 0.0:
            _hide_fruit()
    elif _score_display_timer > 0.0:
        _score_display_timer -= delta
        if _score_display_timer <= 0.0:
            _hide_score()


# -----------------------------------------------
# Game Lifecycle
# -----------------------------------------------

func on_start_game(blinky: Ghost, pinky: Ghost, inky: Ghost, clyde: Ghost) -> void:
    pass


func on_start_level(level: int) -> void:
    animation = LevelData.get_fruit_name(level)
    _points = LevelData.get_fruit_points(level)
    _pellets_eaten = 0


func on_start_round() -> void:
    _hide_fruit()


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
    return _points


func on_pellet_eaten():
    _pellets_eaten += 1
    if _pellets_eaten == FIRST_FRUIT_COUNT or _pellets_eaten == SECOND_FRUIT_COUNT:
        _show_fruit()


func on_fruit_eaten():
    assert(is_available(), "Fruit eaten when not available")
    _hide_fruit()
    _show_score()


# -----------------------------------------------
# Helpers
# -----------------------------------------------

func _show_fruit() -> void:
    _fruit_available_timer = FRUIT_AVAILABLE_SECONDS
    show()


func _hide_fruit() -> void:
    _fruit_available_timer = 0.0
    hide()


func _show_score() -> void:
    _score_display_timer = SCORE_SHOWN_SECONDS
    print("show fruit score: ", _points)


func _hide_score() -> void:
    print("hide fruit score")
    _score_display_timer = 0.0
    hide()
