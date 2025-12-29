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

var _level_index: int
var _next_ghost: int

# Determines whether the individual counters or the global counter is used.
var _use_global_counter: bool = false

# The number of pellets that have been eaten per-ghost.
# These are only incremented when the global counter is disabled.
var _individual_counts: Array[int] = [0, 0, 0, 0]

# The global pellet count.
# This is only incremented when the global counter is enabled.
var _global_count: int = 0

# Ensures ghosts leave the house orderly
var _exit_queue: Array[int] = []
var _is_ghost_exiting := false


# -----------------------------------------------
# Game Lifecycle
# -----------------------------------------------

func on_start_game(blinky: Ghost, pinky: Ghost, inky: Ghost, clyde: Ghost) -> void:
    _ghosts = [blinky, pinky, inky, clyde]
    add_child(blinky)
    add_child(pinky)
    add_child(inky)
    add_child(clyde)


func on_start_level(level: int) -> void:
    _level_index = level - 1
    _next_ghost = GhostId.PINKY
    _use_global_counter = false
    _individual_counts = [0, 0, 0, 0]
    _global_count = 0
    
    for ghost in _ghosts:
        ghost.on_start_level(level)


func on_start_round() -> void:
    _ghosts[GhostId.BLINKY].on_start_round(maze.get_blinky_start_position(), false)
    _ghosts[GhostId.PINKY].on_start_round(maze.get_pinky_start_position(), true)
    _ghosts[GhostId.INKY].on_start_round(maze.get_inky_start_position(), true)
    _ghosts[GhostId.CLYDE].on_start_round(maze.get_clyde_start_position(), true)


func on_playing() -> void:
    for ghost in _ghosts:
        ghost.on_playing()

    _refresh_next_ghost_in_house()
    
    if _use_global_counter:
        return
    
    while _get_pellet_limit(_next_ghost) == 0:
        _queue_leave_house(_next_ghost)
        _next_ghost += 1
        _refresh_next_ghost_in_house()


func on_player_died() -> void:
    for ghost in _ghosts:
        ghost.on_player_died()
    
    _use_global_counter = true
    _global_count = 0

    _next_ghost = GhostId.PINKY
    _refresh_next_ghost_in_house()


func on_level_complete() -> void:
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


func on_pellet_eaten() -> void:
    if _use_global_counter:
        _handle_global_pellet_eaten()
    else:
        _handle_personal_pellet_eaten()


func _handle_personal_pellet_eaten() -> void:
    assert(not _use_global_counter, "Should be updating global counter")

    _refresh_next_ghost_in_house()
    if _next_ghost >= _ghosts.size():
        return

    assert(_get_pellet_limit(_next_ghost) > 0, "Ghost has no pellet limit")

    _individual_counts[_next_ghost] += 1
    if _individual_counts[_next_ghost] >= _get_pellet_limit(_next_ghost):
        _queue_leave_house(_next_ghost)
        _next_ghost += 1
        _refresh_next_ghost_in_house()


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
            _refresh_next_ghost_in_house()


func _try_release_if_in_house(ghost_id: int) -> void:
    if _is_in_house(ghost_id):
        _queue_leave_house(ghost_id)


func _is_in_house(ghost_id: int) -> bool:
    return _ghosts[ghost_id].is_in_house()


func _refresh_next_ghost_in_house() -> void:
    while _next_ghost < _ghosts.size() and not _is_in_house(_next_ghost):
        _next_ghost += 1


# Returns the current pellet limit for the given ghost.
# -1 if all ghosts have exited, 0 if "immediate exit" for this level.
func _get_pellet_limit(ghost_id: GhostId) -> int:
    if ghost_id >= _ghosts.size():
        return -1
    if _level_index >= INDIVIDUAL_PELLET_LIMITS.size():
        return 0
    return INDIVIDUAL_PELLET_LIMITS[_level_index][ghost_id]


func _queue_leave_house(ghost_id: int) -> void:
    _exit_queue.append(ghost_id)
    if not _is_ghost_exiting:
        _run_exit_queue()


func _run_exit_queue() -> void:
    _is_ghost_exiting = true

    while _exit_queue.size() > 0:
        var id: int = _exit_queue.pop_front()
        var ghost: Ghost = _ghosts[id]
        assert(ghost.is_in_house(), "Ghost is not in the house")
        ghost.leave_house()
        await _wait_until_exited(ghost)

    _is_ghost_exiting = false


func _wait_until_exited(ghost: Ghost) -> void:
    while is_instance_valid(ghost) and ghost.is_active():
        await get_tree().process_frame
