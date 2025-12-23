extends Node2D

@export var maze: TileMapLayer
@export var speed := 60.0

@onready var anim := $Sprite
@onready var dbg := $DebugDraw

var cell: Vector2i = Vector2.ZERO
var direction := Vector2.LEFT
var desired_direction := Vector2.ZERO
var moving := false

func _ready():
    anim.animation = "left"
    anim.pause()

    if dbg.visible:
        dbg.maze = maze
        dbg.pacman = self

func start_moving():
    moving = true
    anim.play()

func _process(delta):
    if not moving:
        return

    cell = get_current_cell()
    var center: Vector2 = get_cell_center(cell)
    
    handle_input()
    if can_change_direction(desired_direction):
        global_position = center
        update_direction(desired_direction) 
    elif not can_move_in_direction(direction):        
        # TODO: It would probably be better to continue moving to center
        global_position = center # snap to center of cell
        anim.pause()
        return

    anim.play()
    position += direction * speed * delta

func get_current_cell() -> Vector2i:
    return maze.local_to_map(maze.to_local(global_position))

func get_cell_center(cell: Vector2i) -> Vector2:
    return maze.to_global(maze.map_to_local(cell))
    
func handle_input() -> void:
    if Input.is_action_just_pressed("move_left"):
        desired_direction = Vector2.LEFT
    elif Input.is_action_just_pressed("move_right"):
        desired_direction = Vector2.RIGHT
    elif Input.is_action_just_pressed("move_up"):
        desired_direction = Vector2.UP
    elif Input.is_action_just_pressed("move_down"):
        desired_direction = Vector2.DOWN

func can_change_direction(dir: Vector2) -> bool:
    return dir != direction && can_move_in_direction(dir)

func can_move_in_direction(dir: Vector2) -> bool:
    if dir == Vector2.ZERO:
        return false

    var step := Vector2i(int(dir.x), int(dir.y))
    var next_cell: Vector2i = cell + step
    return maze.get_cell_tile_data(next_cell) == null

func update_direction(dir: Vector2):
    direction = dir
    match direction:
        Vector2.LEFT:
            anim.play("left")
        Vector2.RIGHT:
            anim.play("right")
        Vector2.UP:
            anim.play("up")
        Vector2.DOWN:
            anim.play("down")    
