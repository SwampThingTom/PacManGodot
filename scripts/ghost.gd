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
@export var maze: Maze
@export var ghost_mode: GhostMode
@export var pacman: PacMan
@export var level: int = 1

var moving: bool = false
var state := State.IN_HOUSE

var _mode: GhostMode.Mode
var _cell: Vector2i
var _direction := Vector2i.LEFT

var _next_cell: Vector2i
var _next_cell_center: Vector2
var _next_direction: Vector2i

@onready var anim := $Sprite

func _ready():
    _mode = ghost_mode.get_mode()
    ghost_mode.mode_changed.connect(_on_mode_changed)
    _cell = maze.get_cell(position)
    _determine_next_cell()
    anim.sprite_frames = animations
    anim.animation = "left"
    anim.pause()


func _process(delta):
    if not moving:
        return
    
    if state != State.ACTIVE:
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
    assert(maze.is_open(_cell, _next_direction))
    _update_direction(_next_direction)
    _determine_next_cell()


func start_moving():
    moving = true
    anim.play()


func stop_moving():
    moving = false
    anim.pause()


func _get_speed():
    if maze.is_in_tunnel(_cell):
        return LevelData.get_ghost_tunnel_speed_pixels(level)
    if _mode == GhostMode.Mode.FRIGHTENED:
        return LevelData.get_ghost_fright_speed_pixels(level)
    return LevelData.get_ghost_normal_speed_pixels(level)


func _determine_next_cell() -> void:
    _next_cell = _cell + _direction
    _next_cell_center = maze.get_center_of_cell(_next_cell)
    _next_direction = _get_next_direction(_next_cell, _direction)


func _get_next_direction(from_cell: Vector2i, dir: Vector2i) -> Vector2i:
    # Ghosts can not move up from these tiles
    var safe_zone_cells: Array[Vector2i] = [
        Vector2i(12, 14), Vector2i(15, 14), Vector2i(12, 26), Vector2i(15, 26)
    ]

    # Order matters to break ties the same way the arcade game did
    var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT]

    # Next cell can be outside of the maze if going through a tunnel
    from_cell = maze.wrap_cell(from_cell)
    var is_safe_cell := safe_zone_cells.has(from_cell)

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
        var target: Vector2i = _get_target_tile()
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


func _get_target_tile() -> Vector2i:
    if _mode == GhostMode.Mode.SCATTER:
        return Vector2i(25, 0)
    return pacman.get_cell()


func _update_direction(dir: Vector2i):
    _direction = dir
    match _direction:
        Vector2i.LEFT:
            anim.play("left")
        Vector2i.RIGHT:
            anim.play("right")
        Vector2i.UP:
            anim.play("up")
        Vector2i.DOWN:
            anim.play("down")


func _on_mode_changed(new_mode: GhostMode.Mode):
    if _mode != GhostMode.Mode.FRIGHTENED:
        # Reverse direction when mode changes
        _next_direction = -_direction
    _mode = new_mode
