class_name Ghost
extends Node2D
## Manages a Ghost actor.
##
## Moves a ghost around the maze looking for Pac-Man.

@export var maze: TileMapLayer
@export var level: int = 1

var moving: bool = false

var _tunnel_min_x: int = 0
var _tunnel_max_x: int = 0

var _cell := Vector2i.ZERO
var _direction := Vector2i.LEFT

@onready var anim := $Sprite


func _ready():
    anim.animation = "left"
    anim.pause()
    _calculate_tunnel_coordinates()


func _process(delta):
    if not moving:
        return
    
    _cell = maze.local_to_map(position)
    
    if not _can_move_in_direction(_direction):
        # TODO: Verify how to handle getting ghosts to center of tile
        position = maze.map_to_local(_cell)
        _direction = _get_next_direction(_direction)
        _update_animation()
        return

    var speed: float = LevelData.get_pacman_norm_speed_pixels(level)
    position += _direction * speed * delta
    _handle_tunnel()


func start_moving():
    moving = true
    anim.play()


func stop_moving():
    moving = false
    anim.pause()


func _calculate_tunnel_coordinates() -> void:
    var used := maze.get_used_rect()
    var min_x_cell := used.position.x
    var max_x_cell := used.position.x + used.size.x - 1

    var half_tile := maze.tile_set.tile_size.x * 0.5
    _tunnel_min_x = maze.map_to_local(Vector2i(min_x_cell, 0)).x - half_tile
    _tunnel_max_x = maze.map_to_local(Vector2i(max_x_cell, 0)).x + half_tile


func _can_move_in_direction(dir: Vector2i) -> bool:
    if dir == Vector2i.ZERO:
        return false

    var next_cell: Vector2i = _cell + dir
    return maze.get_cell_tile_data(next_cell) == null


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


func _handle_tunnel() -> void:
    if position.x < _tunnel_min_x:
        position.x = _tunnel_max_x + position.x - _tunnel_min_x
    elif position.x > _tunnel_max_x:
        position.x = _tunnel_min_x + position.x - _tunnel_max_x 
