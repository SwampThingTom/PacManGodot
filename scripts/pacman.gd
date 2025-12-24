extends Node2D

@export var maze: TileMapLayer
@export var pellets: Pellets
@export var level := 1

@onready var anim := $Sprite
@onready var dbg := $DebugDraw

var cell: Vector2i = Vector2.ZERO
var direction := Vector2.LEFT
var desired_direction := Vector2.ZERO
var moving := false
var pause_frames := 0

func _ready():
    anim.animation = "left"
    anim.pause()
    
    if pellets:
        pellets.pellet_eaten.connect(_on_pellet_eaten)
        pellets.all_pellets_eaten.connect(_on_all_pellets_eaten)

    if dbg.visible:
        dbg.maze = maze
        dbg.pacman = self

func start_moving():
    moving = true
    anim.play()
    
func stop_moving():
    moving = false
    anim.pause()

func _process(delta):
    if not moving:
        return
    
    if pause_frames > 0:
        pause_frames -= 1
        return

    cell = maze.local_to_map(maze.to_local(global_position))
    pellets.try_eat_pellet(cell)
    
    # TODO: Needed in case all pellets are eaten. Try to get rid of this.
    if not moving:
        return

    handle_input()
    if can_change_direction(desired_direction):
        position = maze.map_to_local(cell)
        update_direction(desired_direction) 
    elif not can_move_in_direction(direction):        
        # TODO: It would probably be better to continue moving to center
        position = maze.map_to_local(cell) # snap to center of cell
        anim.pause()
        return

    anim.play()
    var speed: float = LevelData.get_pacman_norm_speed_pixels(level)
    position += direction * speed * delta
    
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

func _on_pellet_eaten(is_power_pellet: bool):
    pause_frames = 3 if is_power_pellet else 1

func _on_all_pellets_eaten():
    print("Level Complete!")
    stop_moving()
