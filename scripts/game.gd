class_name Game
extends Node2D
## Manages a single Pac-Man game.
##
## Tracks number of players, current player, scores, and level.

enum State {
    START_GAME,
    START_LEVEL,
    START_ROUND,
    PLAYING,
    PLAYER_DIED,
    LEVEL_COMPLETE,
    GAME_OVER,
}

const BLINKY_FRAMES := preload("res://resources/blinky.tres")
const PINKY_FRAMES  := preload("res://resources/pinky.tres")
const INKY_FRAMES   := preload("res://resources/inky.tres")
const CLYDE_FRAMES  := preload("res://resources/clyde.tres")

@export var pacman_scene: PackedScene
@export var ghost_scene: PackedScene
@export var spawn_duration_sec: float = 3.0 # Seconds to wait before spawning Pac-Man & ghosts
@export var ready_duration_sec: float = 1.0 # Seconds after spawning before start of game

var _state: State = State.START_GAME
var _level: int = 1
var _current_player: int = 0
var _high_score: int = 0
var _scores: Array[int]
var _pacman: PacMan

@onready var maze := $Maze
@onready var pellets: Pellets = $Pellets
@onready var ready_text := $ReadyText
@onready var scores_text: ScoresText = $ScoresText
@onready var ghost_mode: GhostMode = $GhostMode
@onready var ghosts := $Ghosts


func _ready() -> void:
    _start_game()


func _process(delta: float) -> void:
    if _state != State.PLAYING:
        return
    _check_collisions()


# -----------------------------------------------
# State Machine
# -----------------------------------------------

func _transition_to(new_state: State) -> void:
    if _state == new_state:
        return
    _state = new_state
    _enter_state(_state)


func _enter_state(s: State) -> void:
    match s:
        State.START_LEVEL:
            _start_level()
        State.START_ROUND:
            _start_round()
        State.PLAYING:
            _playing()
        State.PLAYER_DIED:
            _player_died()
        State.LEVEL_COMPLETE:
            _level_complete()
        State.GAME_OVER:
            _game_over()


func _start_game() -> void:
    # Initialize game.
    _spawn_actors()
    _connect_signals()
    _reset_scores()
    _transition_to(State.START_LEVEL)


func _start_level() -> void:
    # Reset level-specific data.
    print("START_LEVEL ", _level)
    _pacman.on_start_level(_level)
    ghost_mode.on_start_level(_level)
    ghosts.on_start_level(_level)
    _transition_to(State.START_ROUND)


func _start_round() -> void:
    # Reset round-specific data.
    print("START_ROUND")
    _pacman.on_start_round()
    ghost_mode.on_start_round()
    ghosts.on_start_round()
    await _show_ready_sequence()
    _transition_to(State.PLAYING)


func _playing() -> void:
    # Start playing the next round (timers, counters, movement, etc.)
    print("PLAYING")
    _pacman.on_playing()
    ghost_mode.on_playing()
    ghosts.on_playing()


func _player_died() -> void:
    # Stop playing (timers, counters, movement, etc.)
    # Show death animation
    print("PLAYER_DIED")
    _pacman.on_player_died()
    ghost_mode.on_player_died()
    ghosts.on_player_died()
    await _run_death_sequence()
    _transition_to(State.START_ROUND) # TODO: Only if game not over


func _level_complete() -> void:
    # Stop playing (timers, counters, movement, etc.)
    # Start next level
    print("LEVEL_COMPLETE")
    _pacman.on_level_complete()
    ghost_mode.on_level_complete()
    ghosts.on_level_complete()


func _game_over() -> void:
    print("GAME_OVER")


# -----------------------------------------------
# Transition sequences
# -----------------------------------------------

func _show_ready_sequence() -> void:
    ready_text.show()
    await get_tree().create_timer(spawn_duration_sec).timeout
    _pacman.show()
    ghosts.show_all()
    await get_tree().create_timer(ready_duration_sec).timeout
    ready_text.hide()


func _run_death_sequence() -> void:
    await get_tree().create_timer(1.0).timeout
    ghosts.hide_all()
    await get_tree().create_timer(1.0).timeout
    _pacman.hide()
    await get_tree().create_timer(1.0).timeout


# -----------------------------------------------
# Collision Detection
# -----------------------------------------------

func _check_collisions() -> void:
    # This assumes that all other nodes have already been processed this frame.
    # (i.e., process_priority of this node is larger than other nodes)
    var pacman_cell: Vector2i = _pacman.get_cell()
    for ghost in ghosts.get_ghosts():
        if not ghost.is_active():
            continue
        if ghost.get_cell() == pacman_cell:
            _on_collision(ghost)
            return


func _on_collision(ghost: Ghost) -> void:
    if ghost_mode.get_mode() != GhostMode.Mode.FRIGHTENED:
        _transition_to(State.PLAYER_DIED)


# -----------------------------------------------
# Event Handlers
# -----------------------------------------------

func _on_pellet_eaten(is_power_pellet: bool):
    var points := 50 if is_power_pellet else 10
    _update_current_player_score(points)
    ghosts.on_pellet_eaten()


func _on_all_pellets_eaten():
    _transition_to(State.LEVEL_COMPLETE)


# -----------------------------------------------
# Helpers
# -----------------------------------------------
   
func _reset_scores() -> void:
    _scores = [0, 0]
    scores_text.clear_player_score(0)


func _spawn_actors() -> void:
    assert(_pacman == null, "Actors already spawned")
    _pacman = _make_pacman()
    add_child(_pacman)
    ghosts.on_start_game(_make_blinky(), _make_pinky(), _make_inky(), _make_clyde())


func _connect_signals() -> void:
    pellets.pellet_eaten.connect(_on_pellet_eaten)
    pellets.all_pellets_eaten.connect(_on_all_pellets_eaten)


func _update_current_player_score(points: int) -> void:
    _scores[_current_player] += points
    var current_score := _scores[_current_player]
    scores_text.draw_player_score(_current_player, current_score)
    
    if current_score > _high_score:
        _high_score = current_score
        scores_text.draw_high_score(current_score)


# -----------------------------------------------
# Instantiate Actors
# -----------------------------------------------

func _make_pacman() -> PacMan:
    var pacman: PacMan = pacman_scene.instantiate()
    pacman.maze = maze
    pacman.pellets = pellets
    pacman.hide()
    return pacman    


func _make_blinky() -> Ghost:
    var ghost: Ghost = ghost_scene.instantiate()
    ghost.name = "Blinky"
    ghost.animations = BLINKY_FRAMES
    ghost.chase_target = _get_blinky_chase_target
    ghost.scatter_target = maze.get_blinky_scatter_target()
    ghost.maze = maze
    ghost.ghost_mode = ghost_mode
    ghost.hide()
    return ghost


func _make_pinky() -> Ghost:
    var ghost: Ghost = ghost_scene.instantiate()
    ghost.name = "Pinky"
    ghost.animations = PINKY_FRAMES
    ghost.chase_target = _get_pinky_chase_target
    ghost.scatter_target = maze.get_pinky_scatter_target()
    ghost.maze = maze
    ghost.ghost_mode = ghost_mode
    ghost.hide()
    return ghost


func _make_inky() -> Ghost:
    var ghost: Ghost = ghost_scene.instantiate()
    ghost.name = "Inky"
    ghost.animations = INKY_FRAMES
    ghost.chase_target = _get_inky_chase_target
    ghost.scatter_target = maze.get_inky_scatter_target()
    ghost.maze = maze
    ghost.ghost_mode = ghost_mode
    ghost.hide()
    return ghost


func _make_clyde() -> Ghost:
    var ghost: Ghost = ghost_scene.instantiate()
    ghost.name = "Clyde"
    ghost.animations = CLYDE_FRAMES
    ghost.chase_target = _get_clyde_chase_target
    ghost.scatter_target = maze.get_clyde_scatter_target()
    ghost.maze = maze
    ghost.ghost_mode = ghost_mode
    ghost.hide()
    return ghost


func _get_blinky_chase_target() -> Vector2i:
    return _pacman.get_cell()


func _get_pinky_chase_target() -> Vector2i:
    # TODO: implement original game bug
    return _pacman.get_cell() + _pacman.get_direction() * 4


func _get_inky_chase_target() -> Vector2i:
    # TODO: implement original game bug
    var target_cell: Vector2i = _pacman.get_cell() + _pacman.get_direction() * 2
    var blinky_cell: Vector2i = ghosts.get_ghost(Ghosts.GhostId.BLINKY).get_cell()
    var vector: Vector2i = (target_cell - blinky_cell) * 2
    return blinky_cell + vector


func _get_clyde_chase_target() -> Vector2i:
    var clyde: Ghost = ghosts.get_ghost(Ghosts.GhostId.CLYDE)
    var distance = clyde.get_cell().distance_to(_pacman.get_cell())
    return _pacman.get_cell() if distance >= 8.0 else clyde.scatter_target
