extends Node2D

@export var pacman_scene: PackedScene

@onready var maze := $Maze
@onready var pellets: Pellets = $Pellets
@onready var ready_text := $ReadyText
@onready var scores_text: ScoresText = $ScoresText
@onready var actors := $Actors

const SPAWN_DURATION := 3.0 # Seconds to wait before spawning Pac-Man & ghosts
const READY_DURATION := 1.0 # Seconds after spawning before start of game

var current_player := 0
var scores: Array[int] = [0, 0]
var high_score := 0
var pacman: Node2D

func _ready() -> void:
    reset_scores()
    pellets.pellet_eaten.connect(_on_pellet_eaten)
    pellets.all_pellets_eaten.connect(_on_all_pellets_eaten)
    run_intro()

func reset_scores() -> void:
    scores = [0, 0]
    scores_text.clear_player_score(0)
    scores_text.clear_player_score(1)

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
    pacman.pellets = pellets
    actors.add_child(pacman)

func pacman_start_position() -> Vector2:
    var p1: Vector2 = maze.map_to_local(Vector2i(13, 26))
    var p2: Vector2 = maze.map_to_local(Vector2i(14, 26))
    return (p1 + p2) * 0.5

func _on_pellet_eaten(is_power_pellet: bool):
    var points := 50 if is_power_pellet else 10
    _update_current_player_score(points)

func _update_current_player_score(points: int) -> void:
    scores[current_player] += points
    scores_text.draw_player_score(current_player, scores[current_player])

func _on_all_pellets_eaten():
    print("Level Complete!")
