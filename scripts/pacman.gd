extends CharacterBody2D

@export var maze: TileMapLayer
@export var speed := 60.0

@onready var anim := $Sprite

var direction := Vector2.LEFT
var moving := false

func _ready():
    anim.animation = "left"
    anim.pause()

func start_moving():
    moving = true
    anim.play("left")

func stop_moving():
    moving = false
    anim.pause()

func _process(delta):
    if not moving:
        return

    if is_wall_ahead():
        stop_moving()
        return

    position += direction * speed * delta

func is_wall_ahead() -> bool:
    var ahead_pos = position + direction * 5
    var tile = maze.local_to_map(ahead_pos)
    return maze.get_cell_tile_data(tile) != null
