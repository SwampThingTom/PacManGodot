class_name Ghost
extends Node2D
## Manages a Ghost actor.
##
## Moves a ghost around the maze looking for Pac-Man.

signal revived(ghost_id: Ghosts.GhostId)

enum State {
    IN_HOUSE,
    LEAVE_HOUSE,
    RETURN_HOUSE,
    ACTIVE
}

# These are in priority order per the original arcade game.
const DIRECTIONS: Array[Vector2i] = [
    Vector2i.UP,
    Vector2i.LEFT,
    Vector2i.DOWN,
    Vector2i.RIGHT
]

const CENTER_EPS := 0.05

@export var normal_animations: SpriteFrames
@export var frightened_animations: SpriteFrames
@export var flash_animations: SpriteFrames
@export var eyes_animations: SpriteFrames

@export var maze: Maze
@export var ghost_mode: GhostMode
@export var ghost_id: Ghosts.GhostId
@export var chase_target: Callable # returns a Vector2i for target cell
@export var scatter_target: Vector2i

var _is_playing: bool = false
var _level: int
var _is_frightened: bool
var _state: State
var _elroy_mode: int
var _cell: Vector2i
var _direction := Vector2i.LEFT

var _next_cell: Vector2i
var _next_cell_center: Vector2
var _next_direction: Vector2i
var _direction_when_active: Vector2i

var _start_position: Vector2
var _start_in_house: bool

var _rng = RandomNumberGenerator.new()

@onready var anim := $Sprite

func _ready():
    ghost_mode.mode_changed.connect(_on_mode_changed)
    ghost_mode.frightened_changed.connect(_on_frightened_changed)
    ghost_mode.frightened_flash.connect(_on_frightened_flash)
    anim.sprite_frames = normal_animations
    anim.pause()


func _process(delta):
    if not _is_playing:
        return
    
    if _state == State.IN_HOUSE:
        return
    
    if _move_towards_next_cell(delta):
        _determine_next_cell()


func _move_towards_next_cell(delta: float) -> bool:
    var speed: float = _get_speed()
    var move_distance: float = speed * delta
    var distance_to_next_cell: float = (_next_cell_center - position).length()
    
    if distance_to_next_cell > move_distance + CENTER_EPS:
        # Continue moving to next cell
        position += move_distance * _direction
        return false

    # Snap to cell center
    position = _next_cell_center
    position = maze.handle_tunnel(position)
    _cell = maze.get_cell(position)
    return true


# -----------------------------------------------
# Game Lifecycle
# -----------------------------------------------

func on_start_level(level: int) -> void:
    _level = level


func on_start_round(start_position: Vector2, is_in_house: bool) -> void:
    _start_position = start_position
    _start_in_house = is_in_house
    
    # Reseed rng every round
    _rng.seed = 0

    position = start_position
    _update_state(State.IN_HOUSE if is_in_house else State.ACTIVE)
    _elroy_mode = 0
    _cell = maze.get_cell(position)
    _update_direction(Vector2i.LEFT)
    _next_direction = _direction
    _direction_when_active = _direction
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
    
    
func is_frightened() -> bool:
    return _is_frightened


func leave_house() -> void:
    _direction_when_active = _direction
    if position == maze.get_ghost_home_center_position():
        _next_cell_center = maze.get_ghost_home_exit_position()
        _update_direction(Vector2i.UP)
    else:
        _next_cell_center = maze.get_ghost_home_center_position()
        var direction = Vector2i.LEFT if position.x > _next_cell_center.x else Vector2i.RIGHT
        _update_direction(direction)
    _update_state(State.LEAVE_HOUSE)


func set_elroy_mode(elroy_mode: int) -> void:
    _elroy_mode = elroy_mode


# -----------------------------------------------
# Event Handlers
# -----------------------------------------------

func _on_mode_changed(new_mode: GhostMode.Mode) -> void:
    _reverse_direction()


func _on_frightened_changed(new_is_frightened: bool) -> void:
    if _is_frightened == new_is_frightened:
        return

    _is_frightened = new_is_frightened
    if _is_frightened:
        _reverse_direction()
    
    _update_animation()


func _on_frightened_flash(flash_white: bool) -> void:
    if not _is_frightened:
        return
    anim.sprite_frames = flash_animations if flash_white else frightened_animations


func on_eaten() -> void:
    assert(_is_frightened, "Ghost eaten when not frightened")
    _is_frightened = false
    _update_state(State.RETURN_HOUSE)


# -----------------------------------------------
# Helpers
# -----------------------------------------------

func _reverse_direction() -> void:
    if _state == State.ACTIVE:
        _next_direction = -_direction
    else:
        _direction_when_active = -_direction_when_active


func _get_speed():
    if maze.is_in_tunnel(_cell):
        return LevelData.get_ghost_tunnel_speed_pixels(_level)
    if _is_frightened:
        return LevelData.get_ghost_fright_speed_pixels(_level)
    if _elroy_mode == 2:
        return LevelData.get_elroy_2_speed_pixels(_level)
    if _elroy_mode == 1:
        return LevelData.get_elroy_1_speed_pixels(_level)
    return LevelData.get_ghost_normal_speed_pixels(_level)


func _on_left_house() -> void:
    _update_state(State.ACTIVE)
    _cell = maze.get_cell(position)
    _next_direction = _direction_when_active
    _determine_next_cell_active()


func _on_return_to_house() -> void:
    _update_state(State.IN_HOUSE)

    if _start_in_house:
        # TODO: animate towards start position
        position = _start_position

    _cell = maze.get_cell(position)
    _update_direction(Vector2i.LEFT)
    _next_direction = _direction
    _direction_when_active = _direction
    revived.emit(ghost_id)


func _determine_next_cell() -> void:
    match _state:
        State.IN_HOUSE:
            return
        State.LEAVE_HOUSE:
            _determine_next_cell_leaving_house()
        State.RETURN_HOUSE:
            _determine_next_cell_returning_house()
        State.ACTIVE:
            _determine_next_cell_active()


func _determine_next_cell_leaving_house() -> void:
    if position == maze.get_ghost_home_exit_position():
        _on_left_house()
        return
    
    _next_cell_center = maze.get_ghost_home_exit_position()
    _update_direction(Vector2i.UP)


func _determine_next_cell_returning_house() -> void:
    if position == maze.get_ghost_home_center_position():
        _on_return_to_house()
        return
    
    if _cell == maze.get_ghost_home_target_cell():
        position = maze.get_ghost_home_exit_position()
        _next_cell_center = maze.get_ghost_home_center_position()
        _update_direction(Vector2i.DOWN)
        return
    
    _determine_next_cell_active()


func _determine_next_cell_active() -> void:
    assert(maze.is_open(_cell, _next_direction))
    _update_direction(_next_direction)
    _next_cell = _cell + _direction
    _next_cell_center = maze.get_center_of_cell(_next_cell)
    if _is_frightened:
        assert(_state == State.ACTIVE)
        _next_direction = _get_next_direction_frightened(_next_cell, _direction)
    else:
        _next_direction = _get_next_direction(_next_cell, _direction)


func _get_next_direction_frightened(from_cell: Vector2i, dir: Vector2i) -> Vector2i:
    # Next cell can be outside of the maze if going through a tunnel
    from_cell = maze.wrap_cell(from_cell)

    # Choose a random available direction
    var offset := _rng.randi() & 3
    for dir_index in range(4):
        var next_direction := DIRECTIONS[(dir_index + offset) % 4]
        if next_direction == -dir:
            continue
        if maze.is_open(from_cell, next_direction):
            return next_direction    
    
    # Reverse if no other option
    if maze.is_open(from_cell, -dir):
        return -dir

    # famous last words: shouldn't be possible
    assert(false, "Can't find a direction to travel in.")
    return dir

    
func _get_next_direction(from_cell: Vector2i, dir: Vector2i) -> Vector2i:
    # Next cell can be outside of the maze if going through a tunnel
    from_cell = maze.wrap_cell(from_cell)
    var is_safe_cell := maze.is_safe_zone(from_cell)

    var target: Vector2i = _get_target_cell()
    var best_dir: Vector2i = dir
    var best_score := INF

    for d in DIRECTIONS:
        # Don’t reverse
        if d == -dir:
            continue

        if d == Vector2i.UP and is_safe_cell:
            assert(not _is_frightened)
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
    if _state == State.RETURN_HOUSE:
        return maze.get_ghost_home_target_cell()
    if ghost_mode.get_mode() == GhostMode.Mode.SCATTER and _elroy_mode == 0:
        return scatter_target
    return chase_target.call()


func _update_direction(new_direction: Vector2i):
    _direction = new_direction

    if _is_frightened:
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


func _update_state(new_state: State) -> void:
    _state = new_state
    _update_animation()


func _update_animation() -> void:
    if _state == State.RETURN_HOUSE:
        anim.sprite_frames = eyes_animations
    elif _is_frightened:
        anim.sprite_frames = frightened_animations
    else:
        anim.sprite_frames = normal_animations
