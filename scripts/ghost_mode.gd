class_name GhostMode
extends Node
## Manages the current ghost mode.

signal mode_changed(new_mode: Mode)

enum Mode {
    SCATTER,
    CHASE,
    FRIGHTENED
}

static var _mode_durations: Array[Array] = []

var _running := false
var _level: int = 0
var _level_index: int = 0
var _mode_index: int = 0
var _mode = Mode.SCATTER
var _duration: float = 0.0
var _is_frightened = false
var _frightened_duration: float = 0.0


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
    
    var mode := get_mode()
    if mode == Mode.FRIGHTENED:
        _handle_frightened_mode(delta)
        return
    
    if _mode_index >= _mode_durations[0].size():
        return
        
    _duration -= delta
    if _duration <= 0.0:
        _mode = Mode.CHASE if mode == Mode.SCATTER else Mode.SCATTER
        _mode_index += 1
        _duration = _get_duration()
        _emit_mode_changed()


func _handle_frightened_mode(delta: float) -> void:
    _frightened_duration -= delta
    if _frightened_duration <= 0.0:
        _set_frightened(false)


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
    return _mode if not _is_frightened else Mode.FRIGHTENED


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


func _set_frightened(is_frightened: bool) -> void:
    _is_frightened = is_frightened
    _frightened_duration = LevelData.get_fright_time_seconds(_level)
    _emit_mode_changed()


func _emit_mode_changed() -> void:
    mode_changed.emit(get_mode())
