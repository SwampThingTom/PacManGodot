class_name Ghosts
extends Node2D
## Controls per-level ghost state, including releasing them from their house.
##
## Determining when ghosts leave their house is surprisingly complicated.
##
## When a new level starts, ghosts leave the house using a per-ghost (individual)
## pellet counter. So for the ghost to be released next, it counts how many
## pellets have been released. When the ghost's counter reaches its limit, the
## ghost is released and it starts counting pellets (starting back at 0) for the
## next ghost to be released.
##
## However, when a player dies, the individual pellet counter is disabled and
## instead a global counter is used. This has its own release schedule for
## Pinky and Inky but not for Clyde. When the global counter reaches 32, if
## Clyde is still in the ghost house, the system disables the global counter
## and returns to the individual counter. In this case, the individual counter
## is not reset to 0 so it picks up wherever it left off when the player died.
##
## Finally, there is an inactivity timer that checks how much time has passed
## since the last dot was eaten. Once that reaches a per-level limit, a ghost
## is released from the house (if one is there).

enum GhostId {
    BLINKY,
    PINKY,
    INKY,
    CLYDE
}

# The number of pellets that must be eaten before each ghost will exit the house.
# Only needed for first two levels. From level three on, ghosts will exit immediately.
# This is only used when the global counter is disabled.
const INDIVIDUAL_PELLET_LIMITS := [
    #  blinky pinky inky clyde
    [      0,    0,   30,   60],  # level 1
    [      0,    0,    0,   50],  # level 2
]

# The number of pellets that must be eated before a ghost will exit the house.
# These are only used when the global counter is enabled.
const GLOBAL_PINKY_PELLET_LIMIT := 7
const GLOBAL_INKY_PELLET_LIMIT := 17
const GLOBAL_DEACTIVATE_LIMIT := 32

@export var maze: Maze

# Ghosts in order: blinky, pinky, inky, clyde
var _ghosts: Array[Ghost]

var _is_playing: bool = false
var _level: int
var _is_elroy_paused: bool
var _remaining_pellets: int

# Determines whether the individual counters or the global counter is used.
var _use_global_counter: bool = false

# The next ghost to be released using the individual pellet counters.
var _next_individual_ghost: int

# The number of pellets that have been eaten per-ghost.
# These are only incremented when the global counter is disabled.
var _individual_counts: Array[int] = [0, 0, 0, 0]

# The global pellet count.
# This is only incremented when the global counter is enabled.
var _global_count: int = 0

# Used as a backup to release the next ghost while pellets are not being eaten.
var _inactivity_timer: float = 0.0
var _inactivity_timer_limit: float

# Ensures ghosts leave the house orderly
var _exit_queue: Array[int] = []
var _is_ghost_exiting := false
var _clear_exit_queue := false


func _process(delta: float) -> void:
    if not _is_playing:
        return
    
    _inactivity_timer += delta
    if _inactivity_timer >= _inactivity_timer_limit:
        _release_next_ghost_inactivity()
        _inactivity_timer = 0.0


# -----------------------------------------------
# Game Lifecycle
# -----------------------------------------------

func on_start_game(blinky: Ghost, pinky: Ghost, inky: Ghost, clyde: Ghost) -> void:
    _is_elroy_paused = false
    _ghosts = [blinky, pinky, inky, clyde]
    add_child(blinky)
    add_child(pinky)
    add_child(inky)
    add_child(clyde)

    for ghost in _ghosts:
        ghost.revived.connect(_on_ghost_revived)


func on_start_level(level: int) -> void:
    _level = level
    _use_global_counter = false
    _next_individual_ghost = GhostId.PINKY
    _individual_counts = [0, 0, 0, 0]
    _global_count = 0
    _inactivity_timer_limit = 3.0 if level >= 5 else 4.0
    
    for ghost in _ghosts:
        ghost.on_start_level(level)


func on_start_round() -> void:
    _inactivity_timer = 0.0
    _ghosts[GhostId.BLINKY].on_start_round(maze.get_blinky_start_position(), false)
    _ghosts[GhostId.PINKY].on_start_round(maze.get_pinky_start_position(), true)
    _ghosts[GhostId.INKY].on_start_round(maze.get_inky_start_position(), true)
    _ghosts[GhostId.CLYDE].on_start_round(maze.get_clyde_start_position(), true)


func on_playing() -> void:
    _is_playing = true

    for ghost in _ghosts:
        ghost.on_playing()
    
    _next_individual_ghost = GhostId.PINKY
    if not _use_global_counter:
        _refresh_next_ghost_in_house()
        while _get_pellet_limit(_next_individual_ghost) == 0:
            _release_next_ghost_individual()


func on_player_died() -> void:
    _is_playing = false
    _is_elroy_paused = true

    _reset_exit_queue()
    for ghost in _ghosts:
        ghost.on_player_died()
    
    _use_global_counter = true
    _global_count = 0


func on_level_complete() -> void:
    _is_playing = false
    _reset_exit_queue()
    for ghost in _ghosts:
        ghost.on_level_complete()


# -----------------------------------------------
# Public Methods
# -----------------------------------------------

func get_ghosts() -> Array[Ghost]:
    return _ghosts


func get_ghost(ghost_id: GhostId) -> Ghost:
    return _ghosts[ghost_id]


func show_all() -> void:
    for ghost in _ghosts:
        ghost.show()


func hide_all() -> void:
    for ghost in _ghosts:
        ghost.hide()


func on_pellet_eaten(remaining_pellets: int) -> void:
    _remaining_pellets = remaining_pellets
    _check_elroy_mode()
    _inactivity_timer = 0.0
    if _use_global_counter:
        _handle_global_pellet_eaten()
    else:
        _handle_individual_pellet_eaten()


func _check_elroy_mode() -> void:
    if _is_elroy_paused:
        return
    if _remaining_pellets <= LevelData.get_elroy_2_dots(_level):
        _ghosts[GhostId.BLINKY].set_elroy_mode(2)
    elif _remaining_pellets <= LevelData.get_elroy_1_dots(_level):
        _ghosts[GhostId.BLINKY].set_elroy_mode(1)


func _handle_individual_pellet_eaten() -> void:
    assert(not _use_global_counter, "Should be updating global counter")

    _refresh_next_ghost_in_house()
    if _next_individual_ghost >= _ghosts.size():
        return

    assert(_get_pellet_limit(_next_individual_ghost) > 0, "Ghost has no pellet limit")

    _individual_counts[_next_individual_ghost] += 1
    if _individual_counts[_next_individual_ghost] >= _get_pellet_limit(_next_individual_ghost):
        _release_next_ghost_individual()


func _handle_global_pellet_eaten() -> void:
    assert(_use_global_counter, "Should be updating individual counter")

    _global_count += 1

    if _global_count == GLOBAL_PINKY_PELLET_LIMIT:
        _try_release_if_in_house(GhostId.PINKY)

    if _global_count == GLOBAL_INKY_PELLET_LIMIT:
        _try_release_if_in_house(GhostId.INKY)

    if _global_count == GLOBAL_DEACTIVATE_LIMIT:
        if _is_in_house(GhostId.CLYDE):
            _use_global_counter = false
            _global_count = 0


func _on_ghost_revived(ghost_id: int) -> void:
    assert(_is_in_house(ghost_id), "Revived ghost should be in ghost house")

    if not _use_global_counter:
        _queue_leave_house(ghost_id)
        return

    match ghost_id:
        GhostId.BLINKY:
            _queue_leave_house(ghost_id)
        GhostId.PINKY:
            if _global_count >= GLOBAL_PINKY_PELLET_LIMIT:
                _queue_leave_house(ghost_id)
        GhostId.INKY:
            if _global_count >= GLOBAL_INKY_PELLET_LIMIT:
                _queue_leave_house(ghost_id)
        GhostId.CLYDE:
            # Do nothing here; Clyde never releases via the global counter.
            pass


func _release_next_ghost_individual() -> void:
    assert(not _use_global_counter)
    _queue_leave_house(_next_individual_ghost)
    _next_individual_ghost += 1
    _refresh_next_ghost_in_house()


func _release_next_ghost_inactivity() -> void:
    for ghost in _ghosts:
        if ghost.is_in_house():
            _queue_leave_house(ghost.ghost_id)
            return


func _try_release_if_in_house(ghost_id: int) -> void:
    if _is_in_house(ghost_id):
        _queue_leave_house(ghost_id)


func _is_in_house(ghost_id: int) -> bool:
    return _ghosts[ghost_id].is_in_house()


func _refresh_next_ghost_in_house() -> void:
    while _next_individual_ghost < _ghosts.size() and not _is_in_house(_next_individual_ghost):
        _next_individual_ghost += 1


# Returns the current pellet limit for the given ghost.
# -1 if all ghosts have exited, 0 if "immediate exit" for this level.
func _get_pellet_limit(ghost_id: GhostId) -> int:
    if ghost_id >= _ghosts.size():
        return -1
    var level_index = _level - 1
    if level_index >= INDIVIDUAL_PELLET_LIMITS.size():
        return 0
    return INDIVIDUAL_PELLET_LIMITS[level_index][ghost_id]


func _queue_leave_house(ghost_id: int) -> void:
    _exit_queue.append(ghost_id)
    if not _is_ghost_exiting:
        _run_exit_queue()


func _run_exit_queue() -> void:
    _is_ghost_exiting = true

    while _exit_queue.size() > 0:
        var id: int = _exit_queue.pop_front()
        if _clear_exit_queue:
            continue

        var ghost: Ghost = _ghosts[id]
        if not ghost.is_in_house():
            continue

        ghost.leave_house()
        if id == GhostId.CLYDE:
            _is_elroy_paused = false
            _check_elroy_mode()

        await _wait_until_exited(ghost)

    _is_ghost_exiting = false
    _clear_exit_queue = false


func _reset_exit_queue() -> void:
    if _is_ghost_exiting:
        # This causes `_run_exit_queue()` to clear the queue
        _clear_exit_queue = true
    else:
        _exit_queue.clear()


func _wait_until_exited(ghost: Ghost) -> void:
    while not ghost.is_active() and not _clear_exit_queue:
        await get_tree().process_frame
