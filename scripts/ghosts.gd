class_name Ghosts
extends Node2D
## Manages spawning ghosts and controlling when they release from their house.

enum GhostId {
    BLINKY,
    PINKY,
    INKY,
    CLYDE
}

# The number of pellets that must be eaten before each ghost will exit the house.
# Only needed for first two levels. From level three on, ghosts will exit immediately.
const PELLET_LIMITS := [
    #  blinky pinky inky clyde
    [      0,    0,   30,   60],  # level 1
    [      0,    0,    0,   50],  # level 2
]

# Ghosts in order: blinky, pinky, inky, clyde
var _ghosts: Array[Ghost]

var _level_index: int
var _next_ghost: int
var _pellet_count: int

# Ensures ghosts leave the house orderly
var _exit_queue: Array[int] = []
var _is_ghost_exiting := false


func add_ghosts(blinky: Ghost, pinky: Ghost, inky: Ghost, clyde: Ghost) -> void:
    _ghosts = [blinky, pinky, inky, clyde]
    add_child(blinky)
    add_child(pinky)
    add_child(inky)
    add_child(clyde)


func get_ghosts() -> Array[Ghost]:
    return _ghosts


func get_ghost(ghost_id: GhostId) -> Ghost:
    return _ghosts[ghost_id]


func reset_to_level(level: int) -> void:
    _level_index = level - 1
    _pellet_count = 0
    _next_ghost = GhostId.PINKY


func start_round() -> void:
    start_moving()    
    while _get_pellet_limit(_next_ghost) == 0:
        _queue_leave_house(_next_ghost)
        _next_ghost += 1


func start_moving() -> void:
    for ghost in _ghosts:
        ghost.start_moving()

    
func stop_moving() -> void:
    for ghost in _ghosts:
        ghost.stop_moving()


func show_all() -> void:
    for ghost in _ghosts:
        ghost.show()


func hide_all() -> void:
    for ghost in _ghosts:
        ghost.hide()


func reset_to_start_positions() -> void:
    for ghost in _ghosts:
        ghost.reset_to_start_position()


func pellet_eaten() -> void:
    var pellet_limit = _get_pellet_limit(_next_ghost)
    if pellet_limit == -1:
        return

    _pellet_count += 1
    if _pellet_count >= pellet_limit:
        _queue_leave_house(_next_ghost)
        _pellet_count = 0
        _next_ghost += 1


# Returns the current pellet limit for the given ghost,
# or -1 if all ghosts have exited.
func _get_pellet_limit(ghost_id: GhostId):
    if ghost_id >= _ghosts.size():
        return -1
    if _level_index >= PELLET_LIMITS.size():
        return 0
    return PELLET_LIMITS[_level_index][ghost_id]


func _queue_leave_house(ghost_id: int) -> void:
    _exit_queue.append(ghost_id)
    if not _is_ghost_exiting:
        _run_exit_queue()


func _run_exit_queue() -> void:
    _is_ghost_exiting = true

    while _exit_queue.size() > 0:
        var id: int = _exit_queue.pop_front()
        var ghost: Ghost = _ghosts[id]
        assert(ghost.state == Ghost.State.IN_HOUSE, "Ghost is not in the house")
        ghost.leave_house()
        await _wait_until_exited(ghost)

    _is_ghost_exiting = false


func _wait_until_exited(ghost: Ghost) -> void:
    while is_instance_valid(ghost) and ghost.state != Ghost.State.ACTIVE:
        await get_tree().process_frame
