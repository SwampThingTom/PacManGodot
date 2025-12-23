extends Node2D

@export var pacman_scene: PackedScene

@onready var maze := $Maze
@onready var pellets := $Pellets
@onready var ready_text := $ReadyText
@onready var actors := $Actors

const SPAWN_DURATION := 3.0 # Seconds to wait before spawning Pac-Man & ghosts
const READY_DURATION := 1.0 # Seconds after spawning before start of game

var pacman: Node2D

func _ready() -> void:
    run_intro()

func run_intro() -> void:
    ready_text.visible = true
    await get_tree().create_timer(SPAWN_DURATION).timeout
    spawn_actors()
    await get_tree().create_timer(READY_DURATION).timeout
    ready_text.visible = false
    pacman.start_moving()

func spawn_actors() -> void:
    pacman = pacman_scene.instantiate()
    pacman.global_position = pacman_start_position()
    pacman.maze = maze
    actors.add_child(pacman)

func pacman_start_position() -> Vector2:
    var p1: Vector2 = maze.map_to_local(Vector2i(13, 26))
    var p2: Vector2 = maze.map_to_local(Vector2i(14, 26))
    return (p1 + p2) * 0.5
