class_name PacMan
extends Node2D
## Manages the Pac-Man actor.
##
## Moves Pac-Man around the maze based on user input.

@export var maze: TileMapLayer
@export var pellets: Pellets
@export var level: int = 1

var moving: bool = false

var _tunnel_min_x: int = 0
var _tunnel_max_x: int = 0

var _cell := Vector2i.ZERO
var _direction := Vector2i.LEFT
var _desired_direction := Vector2i.ZERO
var _pause_frames: int = 0

@onready var anim := $Sprite
@onready var dbg := $DebugDraw


func _ready():
    anim.animation = "left"
    anim.pause()
    _calculate_tunnel_coordinates()
    _connect_signals()
    
    if dbg.visible:
        dbg.maze = maze
        dbg.pacman = self


func _process(delta):
    if not moving:
        return
    
    # Always handle input even when pausing movement
    _handle_input()

    if _pause_frames > 0:
        _pause_frames -= 1
        return

    _cell = maze.local_to_map(position)
    pellets.try_eat_pellet(_cell)
    
    # TODO: Needed in case all pellets are eaten. Try to get rid of this.
    if not moving:
        return
    
    if _can_change_direction(_desired_direction):
        position = maze.map_to_local(_cell)
        _update_direction(_desired_direction)
    elif not _can_move_in_direction(_direction):
        position = maze.map_to_local(_cell) # snap to center of cell
        anim.pause()
        return

    anim.play()
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


func _connect_signals() -> void:
    pellets.pellet_eaten.connect(_on_pellet_eaten)
    pellets.all_pellets_eaten.connect(_on_all_pellets_eaten)


func _handle_input() -> void:
    if Input.is_action_just_pressed("move_left"):
        _desired_direction = Vector2i.LEFT
    elif Input.is_action_just_pressed("move_right"):
        _desired_direction = Vector2i.RIGHT
    elif Input.is_action_just_pressed("move_up"):
        _desired_direction = Vector2i.UP
    elif Input.is_action_just_pressed("move_down"):
        _desired_direction = Vector2i.DOWN


func _can_change_direction(dir: Vector2i) -> bool:
    return dir != _direction and _can_move_in_direction(dir)


func _can_move_in_direction(dir: Vector2i) -> bool:
    if dir == Vector2i.ZERO:
        return false

    var next_cell: Vector2i = _cell + dir
    return maze.get_cell_tile_data(next_cell) == null


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


func _handle_tunnel() -> void:
    if position.x < _tunnel_min_x:
        position.x = _tunnel_max_x + position.x - _tunnel_min_x
    elif position.x > _tunnel_max_x:
        position.x = _tunnel_min_x + position.x - _tunnel_max_x 


func _on_pellet_eaten(is_power_pellet: bool):
    _pause_frames = 3 if is_power_pellet else 1


func _on_all_pellets_eaten():
    stop_moving()
