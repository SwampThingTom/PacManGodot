class_name Ghost
extends Node2D
## Manages a Ghost actor.
##
## Moves a ghost around the maze looking for Pac-Man.

enum State {
    IN_HOUSE,
    LEAVE_HOUSE,
    RETURN_HOUSE,
    ACTIVE
}

const CENTER_EPS := 0.05

@export var animations: SpriteFrames
@export var frightened_animations: SpriteFrames
@export var maze: Maze
@export var ghost_mode: GhostMode
@export var chase_target: Callable # returns a Vector2i for target cell
@export var scatter_target: Vector2i

var _is_playing: bool = false
var _level: int
var _mode: GhostMode.Mode
var _state: State
var _cell: Vector2i
var _direction := Vector2i.LEFT

var _next_cell: Vector2i
var _next_cell_center: Vector2
var _next_direction: Vector2i
var _direction_when_active: Vector2i

@onready var anim := $Sprite

func _ready():
    ghost_mode.mode_changed.connect(_on_mode_changed)
    anim.sprite_frames = animations
    anim.pause()


func _process(delta):
    if not _is_playing:
        return
    
    if _state == State.IN_HOUSE:
        return
    
    var speed: float = _get_speed()
    var move_distance: float = speed * delta
    var distance_to_next_cell: float = (_next_cell_center - position).length()
    
    if distance_to_next_cell > move_distance + CENTER_EPS:
        # Continue moving to next cell
        # Note: don't handle tunnel here -- only teleport at cell center.
        position += move_distance * _direction
        return
    
    # Snap to cell center
    position = _next_cell_center
    position = maze.handle_tunnel(position)
    _cell = maze.get_cell(position)
    
    if _state == State.ACTIVE:
        assert(maze.is_open(_cell, _next_direction))
        _update_direction(_next_direction)

    _determine_next_cell()


# -----------------------------------------------
# Game Lifecycle
# -----------------------------------------------

func on_start_level(level: int) -> void:
    _level = level


func on_start_round(start_position: Vector2, is_in_house: bool) -> void:
    position = start_position
    _state = State.IN_HOUSE if is_in_house else State.ACTIVE
    _mode = ghost_mode.get_mode()
    _cell = maze.get_cell(position)
    _update_direction(Vector2i.LEFT)
    _determine_next_cell()


func on_playing() -> void:
    _is_playing = true
    anim.play()


func on_player_died() -> void:
    _is_playing = false


func on_level_complete() -> void:
    _is_playing = false


# -----------------------------------------------
# Public Methods
# -----------------------------------------------

func get_cell() -> Vector2i:
    return _cell


func is_in_house() -> bool:
    return _state == State.IN_HOUSE


func is_active() -> bool:
    return _state == State.ACTIVE


func leave_house():
    _direction_when_active = _direction
    if position == maze.get_ghost_home_center_position():
        _next_cell_center = maze.get_ghost_home_exit_position()
        _update_direction(Vector2i.UP)
    else:
        _next_cell_center = maze.get_ghost_home_center_position()
        var direction = Vector2i.LEFT if position.x > _next_cell_center.x else Vector2i.RIGHT
        _update_direction(direction)
    _state = State.LEAVE_HOUSE


# -----------------------------------------------
# Event Handlers
# -----------------------------------------------

func _on_mode_changed(new_mode: GhostMode.Mode):
    # Reverse direction when mode changes (except when leaving FRIGHTENED)
    if _mode != GhostMode.Mode.FRIGHTENED or new_mode == GhostMode.Mode.FRIGHTENED:
        _next_direction = -_direction if _state == State.ACTIVE else -_direction_when_active
    _mode = new_mode
    _update_animation()
    

# -----------------------------------------------
# Helpers
# -----------------------------------------------

func _get_speed():
    if maze.is_in_tunnel(_cell):
        return LevelData.get_ghost_tunnel_speed_pixels(_level)
    if _mode == GhostMode.Mode.FRIGHTENED:
        return LevelData.get_ghost_fright_speed_pixels(_level)
    return LevelData.get_ghost_normal_speed_pixels(_level)


func _determine_next_cell() -> void:
    if _state == State.LEAVE_HOUSE:
        # don't return early, state may change to ACTIVE
        _determine_next_cell_leaving_house()
    
    if _state != State.ACTIVE:
        return
    
    _next_cell = _cell + _direction
    _next_cell_center = maze.get_center_of_cell(_next_cell)
    _next_direction = _get_next_direction(_next_cell, _direction)


func _determine_next_cell_leaving_house() -> void:
    if position == maze.get_ghost_home_exit_position():
        _cell = maze.get_cell(position)
        _direction = _direction_when_active
        _state = State.ACTIVE
        return
    
    _next_cell_center = maze.get_ghost_home_exit_position()
    _update_direction(Vector2i.UP)


func _get_next_direction(from_cell: Vector2i, dir: Vector2i) -> Vector2i:
    assert(_state == State.ACTIVE, "_get_next_direction only valid for ACTIVE state")

    # Order matters to break ties the same way the arcade game did
    var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT]

    # Next cell can be outside of the maze if going through a tunnel
    from_cell = maze.wrap_cell(from_cell)
    var is_safe_cell := maze.is_safe_zone(from_cell)

    var target: Vector2i = _get_target_cell()
    var best_dir: Vector2i = dir
    var best_score := INF

    for d in directions:
        # Don’t reverse
        if d == -dir:
            continue

        if d == Vector2i.UP and is_safe_cell and _mode != GhostMode.Mode.FRIGHTENED:
            continue

        if not maze.is_open(from_cell, d):
            continue

        var next_cell: Vector2i = from_cell + d
        var dx := next_cell.x - target.x
        var dy := next_cell.y - target.y
        var score := dx * dx + dy * dy

        if score < best_score:
            best_score = score
            best_dir = d

    # Reverse if no other option
    if best_score == INF and maze.can_move_from_cell(from_cell, -dir):
        return -dir

    return best_dir


func _get_target_cell() -> Vector2i:
    if _mode == GhostMode.Mode.SCATTER:
        return scatter_target
    return chase_target.call()


func _update_direction(dir: Vector2i):
    _direction = dir

    if _mode == GhostMode.Mode.FRIGHTENED:
        return

    match _direction:
        Vector2i.LEFT:
            anim.play("left")
        Vector2i.RIGHT:
            anim.play("right")
        Vector2i.UP:
            anim.play("up")
        Vector2i.DOWN:
            anim.play("down")


func _update_animation() -> void:
    if _mode == GhostMode.Mode.FRIGHTENED:
        anim.sprite_frames = frightened_animations
    else:
        anim.sprite_frames = animations
