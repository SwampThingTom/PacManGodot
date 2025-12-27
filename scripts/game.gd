extends Node2D
## Manages a single Pac-Man game.
##
## Tracks number of players, current player, scores, and level.

const GHOST_SCENE := preload("res://scenes/ghost.tscn")
const BLINKY_FRAMES := preload("res://resources/blinky.tres")
const PINKY_FRAMES  := preload("res://resources/pinky.tres")
const INKY_FRAMES   := preload("res://resources/inky.tres")
const CLYDE_FRAMES  := preload("res://resources/clyde.tres")

@export var pacman_scene: PackedScene
@export var ghost_scene: PackedScene
@export var spawn_duration_sec: float = 3.0 # Seconds to wait before spawning Pac-Man & ghosts
@export var ready_duration_sec: float = 1.0 # Seconds after spawning before start of game

var _current_player: int = 0
var _scores: Array[int] = [0, 0]
var _high_score: int = 0
var _pacman: PacMan

@onready var maze := $Maze
@onready var pellets: Pellets = $Pellets
@onready var ready_text := $ReadyText
@onready var scores_text: ScoresText = $ScoresText
@onready var ghost_mode: GhostMode = $GhostMode
@onready var ghosts := $Ghosts


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
    ghosts.start_moving()
    ghost_mode.start(1)


func _spawn_actors() -> void:
    _pacman = _make_pacman()
    add_child(_pacman)
    
    # order matters
    ghosts.add_child(_make_blinky())    
    ghosts.add_child(_make_pinky())
    ghosts.add_child(_make_inky())
    ghosts.add_child(_make_clyde())


func _make_pacman() -> PacMan:
    var pacman: PacMan = pacman_scene.instantiate()
    pacman.global_position = maze.get_pacman_start_position()
    pacman.maze = maze
    pacman.pellets = pellets
    return pacman    

func _make_blinky() -> Ghost:
    var ghost: Ghost = ghost_scene.instantiate()
    ghost.name = "Blinky"
    ghost.animations = BLINKY_FRAMES
    ghost.global_position = maze.get_blinky_start_position()
    ghost.state = Ghost.State.ACTIVE
    ghost.maze = maze
    ghost.pacman = _pacman
    ghost.ghost_mode = ghost_mode
    return ghost


func _make_pinky() -> Ghost:
    var ghost: Ghost = ghost_scene.instantiate()
    ghost.name = "Pinky"
    ghost.animations = PINKY_FRAMES
    ghost.global_position = maze.get_pinky_start_position()
    ghost.state = Ghost.State.IN_HOUSE
    ghost.maze = maze
    ghost.pacman = _pacman
    ghost.ghost_mode = ghost_mode
    return ghost


func _make_inky() -> Ghost:
    var ghost: Ghost = ghost_scene.instantiate()
    ghost.name = "Inky"
    ghost.animations = INKY_FRAMES
    ghost.global_position = maze.get_inky_start_position()
    ghost.state = Ghost.State.IN_HOUSE
    ghost.maze = maze
    ghost.pacman = _pacman
    ghost.ghost_mode = ghost_mode
    return ghost


func _make_clyde() -> Ghost:
    var ghost: Ghost = ghost_scene.instantiate()
    ghost.name = "Clyde"
    ghost.animations = CLYDE_FRAMES
    ghost.global_position = maze.get_clyde_start_position()
    ghost.state = Ghost.State.IN_HOUSE
    ghost.maze = maze
    ghost.pacman = _pacman
    ghost.ghost_mode = ghost_mode
    return ghost


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
