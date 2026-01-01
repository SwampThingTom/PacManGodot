class_name GhostMode
extends Node
## Manages the current ghost mode (scatter, chase, or frightened).

signal mode_changed(new_mode: Mode)
signal frightened_changed(is_frightened: bool)
signal frightened_flash(flash_white: bool)

enum Mode { SCATTER, CHASE }

# Time spent in a single color (blue or white) while flashing.
const FLASH_COLOR_SECONDS: float = 8.0 / 60.0

static var _mode_durations: Array[Array] = []

var _running := false
var _level: int = 0
var _level_index: int = 0
var _mode_index: int = 0
var _mode = Mode.SCATTER
var _duration: float = 0.0
var _is_frightened = false
var _frightened_duration: float = 0.0
var _next_flash_time: float
var _next_flash_is_white: bool


static func _static_init() -> void:
    # Level 1
    var durations_1: Array[float] = [7.0, 20.0, 7.0, 20.0, 5.0,   20.0, 5.0]
    # Level 2-4
    var durations_2: Array[float] = [7.0, 20.0, 7.0, 20.0, 5.0, 1033.0, 0.016]
    # Level 5+
    var durations_3: Array[float] = [5.0, 20.0, 5.0, 20.0, 5.0, 1037.0, 0.016]
    _mode_durations = [durations_1, durations_2, durations_3]


func _process(delta: float) -> void:
    if not _running:
        return
    
    if _is_frightened:
        _process_frightened_mode(delta)
        return
    
    if _mode_index >= _mode_durations[0].size():
        return
    
    _duration -= delta
    if _duration <= 0.0:
        _mode = Mode.CHASE if _mode == Mode.SCATTER else Mode.SCATTER
        _mode_index += 1
        _duration = _get_duration()
        _emit_mode_changed()


# -----------------------------------------------
# Game Lifecycle
# -----------------------------------------------

func on_start_level(level: int) -> void:
    _level = level
    _level_index = _get_level_index(_level)


func on_start_round() -> void:
    _mode_index = 0
    _mode = Mode.SCATTER
    _duration = _get_duration()
    _is_frightened = false
    _frightened_duration = 0.0
    

func on_playing() -> void:
    _running = true


func on_player_died() -> void:
    _running = false


func on_level_complete() -> void:
    _running = false


# -----------------------------------------------
# Public Methods
# -----------------------------------------------

func get_mode() -> Mode:
    return _mode


func start_frightened() -> void:
    _set_frightened(true)


# -----------------------------------------------
# Helpers
# -----------------------------------------------

func _get_duration() -> float:
    if _mode_index >= _mode_durations[0].size():
        return 0.0
    return _mode_durations[_level_index][_mode_index]


func _get_level_index(level: int) -> int:
    if level == 1:
        return 0
    if level < 5:
        return 1
    return 2


func _process_frightened_mode(delta: float) -> void:
    assert(_is_frightened, "Frightened duration is not valid when not frightened")
    _frightened_duration -= delta
    if _frightened_duration <= 0.0:
        _set_frightened(false)
        return
    
    while _next_flash_time > 0.0 and _frightened_duration <= _next_flash_time:
       _change_frightened_flash()


func _set_frightened(is_frightened: bool) -> void:
    _is_frightened = is_frightened
    
    if _is_frightened:
        _frightened_duration = LevelData.get_fright_time_seconds(_level)
        _next_flash_time = LevelData.get_fright_flashes(_level) * FLASH_COLOR_SECONDS * 2.0
        _next_flash_is_white = true

    frightened_changed.emit(_is_frightened)


func _change_frightened_flash() -> void:
    frightened_flash.emit(_next_flash_is_white)
    _next_flash_time = _next_flash_time - FLASH_COLOR_SECONDS
    _next_flash_is_white = not _next_flash_is_white


func _emit_mode_changed() -> void:
    mode_changed.emit(_mode)
