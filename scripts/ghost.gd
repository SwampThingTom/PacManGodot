class_name Ghost
extends Node2D
## Manages a Ghost actor.
##
## Moves a ghost around the maze looking for Pac-Man.

@export var maze: Maze
@export var level: int = 1

var moving: bool = false

var _cell := Vector2i.ZERO
var _direction := Vector2i.LEFT

@onready var anim := $Sprite


func _ready():
    anim.animation = "left"
    anim.pause()


func _process(delta):
    if not moving:
        return
    
    _cell = maze.get_cell(position)
    
    if not _can_move_in_direction(_direction):
        # TODO: Verify how to handle getting ghosts to center of tile
        position = maze.get_center_of_cell(_cell)
        _direction = _get_next_direction(_direction)
        _update_animation()
        return

    var speed: float = LevelData.get_ghost_normal_speed_pixels(level)
    position += _direction * speed * delta
    position = maze.handle_tunnel(position)


func start_moving():
    moving = true
    anim.play()


func stop_moving():
    moving = false
    anim.pause()


func _can_move_in_direction(dir: Vector2i) -> bool:
    assert(dir != Vector2i.ZERO)
    return maze.is_open(_cell, dir)


func _get_next_direction(dir: Vector2i) -> Vector2i:
    while range(3):
        var next_dir := _get_clockwise_direction(dir)
        if _can_move_in_direction(next_dir):
            return next_dir
        dir = next_dir
    return Vector2i.ZERO # should never happen


func _get_clockwise_direction(dir: Vector2i) -> Vector2i:
    match dir:
        Vector2i.LEFT:
            return Vector2i.UP
        Vector2i.UP:
            return Vector2i.RIGHT
        Vector2i.RIGHT:
            return Vector2i.DOWN
        Vector2i.DOWN:
            return Vector2i.LEFT
    return Vector2i.ZERO # should never happen


func _update_animation() -> void:
    match _direction:
        Vector2i.LEFT:
            anim.animation = "left"
        Vector2i.UP:
            anim.animation = "up"
        Vector2i.RIGHT:
            anim.animation = "right"
        Vector2i.DOWN:
            anim.animation = "down"
