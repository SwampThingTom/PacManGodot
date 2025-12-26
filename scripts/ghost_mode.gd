class_name GhostMode
extends Node
## Manages the current ghost mode.

enum Mode {
    SCATTER,
    CHASE,
    FRIGHTENED
}

static var _mode_durations: Array[Array] = []

var _running := false
var _level: int = 0
var _mode_index: int = 0
var _mode = Mode.SCATTER
var _duration: float = 0.0
var _is_frightened = false


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
        return
    
    if _mode_index >= _mode_durations[0].size():
        return
        
    _duration -= delta
    if _duration <= 0.0:
        _mode = Mode.CHASE if mode == Mode.SCATTER else Mode.SCATTER
        _mode_index += 1
        _duration = _get_duration(_level)


func start(level: int) -> void:
    assert(not _running, "Ghost Mode has already started")
    _running = true
    _level = level
    _mode_index = 0
    _mode = Mode.SCATTER
    _duration = _get_duration(_level)


func stop() -> void:
    _running = false


func get_mode() -> Mode:
    return _mode if not _is_frightened else Mode.FRIGHTENED


func _get_duration(level: int) -> float:
    if _mode_index >= _mode_durations[0].size():
        return 0.0 

    var level_index: int = _get_level_index(level)
    return _mode_durations[level_index][_mode_index]


func _get_level_index(level: int) -> int:
    if level == 1:
        return 0
    if level < 5:
        return 1
    return 2
