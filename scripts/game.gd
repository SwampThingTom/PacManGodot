extends Node2D
## Manages a single Pac-Man game.
##
## Tracks number of players, current player, scores, and level.

@export var pacman_scene: PackedScene
@export var ghost_scene: PackedScene
@export var spawn_duration_sec: float = 3.0 # Seconds to wait before spawning Pac-Man & ghosts
@export var ready_duration_sec: float = 1.0 # Seconds after spawning before start of game

var _current_player: int = 0
var _scores: Array[int] = [0, 0]
var _high_score: int = 0
var _pacman: PacMan
var _ghost: Ghost

@onready var maze := $Maze
@onready var pellets: Pellets = $Pellets
@onready var ready_text := $ReadyText
@onready var scores_text: ScoresText = $ScoresText
@onready var ghost_mode: GhostMode = $GhostMode
@onready var actors := $Actors


func _ready() -> void:
    _reset_scores()
    _connect_signals()
    _run_intro()


func _reset_scores() -> void:
    _scores = [0, 0]
    scores_text.clear_player_score(0)


func _connect_signals() -> void:
    pellets.pellet_eaten.connect(_on_pellet_eaten)
    pellets.all_pellets_eaten.connect(_on_all_pellets_eaten)


func _run_intro() -> void:
    ready_text.visible = true
    await get_tree().create_timer(spawn_duration_sec).timeout
    _spawn_actors()
    await get_tree().create_timer(ready_duration_sec).timeout
    ready_text.visible = false
    _pacman.start_moving()
    _ghost.start_moving()
    ghost_mode.start(1)


func _spawn_actors() -> void:
    _pacman = pacman_scene.instantiate()
    _pacman.global_position = _get_pacman_start_position()
    _pacman.maze = maze
    _pacman.pellets = pellets
    actors.add_child(_pacman)
    
    _ghost = ghost_scene.instantiate()
    _ghost.global_position = _get_blinky_start_position()
    _ghost.maze = maze
    actors.add_child(_ghost)


func _get_pacman_start_position() -> Vector2:
    var p1: Vector2 = maze.map_to_local(Vector2i(13, 26))
    var p2: Vector2 = maze.map_to_local(Vector2i(14, 26))
    return (p1 + p2) * 0.5


func _get_blinky_start_position() -> Vector2:
    var p1: Vector2 = maze.map_to_local(Vector2i(13, 14))
    var p2: Vector2 = maze.map_to_local(Vector2i(14, 14))
    return (p1 + p2) * 0.5


func _on_pellet_eaten(is_power_pellet: bool):
    var points := 50 if is_power_pellet else 10
    _update_current_player_score(points)


func _update_current_player_score(points: int) -> void:
    _scores[_current_player] += points
    var current_score := _scores[_current_player]
    scores_text.draw_player_score(_current_player, current_score)
    
    if current_score > _high_score:
        _high_score = current_score
        scores_text.draw_high_score(current_score)


func _on_all_pellets_eaten():
    print("Level Complete!")
