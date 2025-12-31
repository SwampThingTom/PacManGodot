class_name PacMan
extends Node2D
## Manages the Pac-Man actor.
##
## Moves Pac-Man around the maze based on user input.

@export var maze: Maze
@export var pellets: Pellets

var _is_playing: bool = false
var _level: int = 1
var _cell := Vector2i.ZERO
var _direction := Vector2i.LEFT
var _desired_direction := Vector2i.ZERO
var _pause_frames: int = 0

@onready var anim := $Sprite
@onready var dbg := $DebugDraw


func _ready():
    pellets.pellet_eaten.connect(_on_pellet_eaten)
    if dbg.visible:
        dbg.maze = maze
        dbg.pacman = self


func _process(delta):
    if not _is_playing:
        return
    
    # Always handle input even when pausing movement
    _handle_input()

    if _pause_frames > 0:
        _pause_frames -= 1
        return

    _cell = maze.get_cell(position)
    pellets.try_eat_pellet(_cell)
    
    # TODO: Needed in case all pellets are eaten. Try to get rid of this.
    if not _is_playing:
        return
    
    if _can_change_direction(_desired_direction):
        position = maze.get_center_of_cell(_cell)
        _update_direction(_desired_direction)
    elif not _can_move_in_direction(_direction):
        position = maze.get_center_of_cell(_cell) # snap to center of cell
        anim.pause()
        return

    anim.play()
    var speed: float = LevelData.get_pacman_normal_speed_pixels(_level)
    position += _direction * speed * delta
    position = maze.handle_tunnel(position)


# -----------------------------------------------
# Game Lifecycle
# -----------------------------------------------

func on_start_level(level: int) -> void:
    _level = level


func on_start_round() -> void:
    position = maze.get_pacman_start_position()
    _cell = maze.get_cell(position)
    _update_direction(Vector2i.LEFT)
    _desired_direction = Vector2i.ZERO
    _pause_frames = 0
    anim.pause()


func on_playing() -> void:
    _is_playing = true
    anim.play()


func on_player_died() -> void:
    _is_playing = false
    anim.pause()


func on_level_complete() -> void:
    _is_playing = false
    anim.pause()


# -----------------------------------------------
# Public Methods
# -----------------------------------------------

func get_cell() -> Vector2i:
    return _cell


func get_direction() -> Vector2i:
    return _direction


func play_death_animation() -> void:
    anim.play("die")
    await anim.animation_finished

# -----------------------------------------------
# Event Handlers
# -----------------------------------------------

func _on_pellet_eaten(is_power_pellet: bool):
    _pause_frames = 3 if is_power_pellet else 1


# -----------------------------------------------
# Helpers
# -----------------------------------------------

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
    if dir == Vector2i.ZERO or dir == _direction:
        return false
    return _can_move_in_direction(dir)


func _can_move_in_direction(dir: Vector2i) -> bool:
    assert(dir != Vector2i.ZERO)
    return maze.is_open(_cell, dir)


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
