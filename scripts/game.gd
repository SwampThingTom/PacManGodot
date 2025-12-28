extends Node2D
## Manages a single Pac-Man game.
##
## Tracks number of players, current player, scores, and level.

enum State {
    GET_READY,
    PLAYING,
    DYING,
    GAME_OVER
}

const BLINKY_FRAMES := preload("res://resources/blinky.tres")
const PINKY_FRAMES  := preload("res://resources/pinky.tres")
const INKY_FRAMES   := preload("res://resources/inky.tres")
const CLYDE_FRAMES  := preload("res://resources/clyde.tres")

@export var pacman_scene: PackedScene
@export var ghost_scene: PackedScene
@export var spawn_duration_sec: float = 3.0 # Seconds to wait before spawning Pac-Man & ghosts
@export var ready_duration_sec: float = 1.0 # Seconds after spawning before start of game

var _level: int = 1
var _state: State
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
    _spawn_actors()
    _connect_signals()
    _start_level(1)
    

func _process(delta: float) -> void:
    if _state != State.PLAYING:
        return
    
    # This assumes that all other nodes have already been processed this frame.
    # (i.e., process_priority of this node is larger than other nodes)
    var pacman_cell: Vector2i = _pacman.get_cell()
    for ghost in ghosts.get_ghosts():
        if ghost.state != Ghost.State.ACTIVE:
            continue
        
        if ghost.get_cell() == pacman_cell:
            _handle_collision(ghost)
            return


func _reset_scores() -> void:
    _scores = [0, 0]
    scores_text.clear_player_score(0)


func _spawn_actors() -> void:
    assert(_pacman == null, "Actors already spawned")

    _pacman = _make_pacman()
    add_child(_pacman)
    
    ghosts.add_ghosts(
        _make_blinky(),
        _make_pinky(),
        _make_inky(),
        _make_clyde()
    )


func _connect_signals() -> void:
    pellets.pellet_eaten.connect(_on_pellet_eaten)
    pellets.all_pellets_eaten.connect(_on_all_pellets_eaten)


func _start_level(level: int) -> void:
    _level = level
    ghosts.reset_to_level(_level)
    _run_intro()


func _run_intro() -> void:
    _state = State.GET_READY
    ready_text.show()
    await get_tree().create_timer(spawn_duration_sec).timeout

    _show_actors()
    await get_tree().create_timer(ready_duration_sec).timeout

    _state = State.PLAYING
    ready_text.hide()
    _pacman.start_moving()
    ghosts.start_round()
    ghost_mode.start(_level)


func _handle_collision(ghost: Ghost) -> void:
    if ghost_mode.get_mode() != GhostMode.Mode.FRIGHTENED:
        _handle_pacman_death()


func _handle_pacman_death() -> void:
    _state = State.DYING
    _stop_actors()
    ghosts.on_life_lost()
    await get_tree().create_timer(1.0).timeout

    ghosts.hide_all()
    # TODO: await _pacman.play_death_animation()
    await get_tree().create_timer(1.0).timeout

    _pacman.hide()
    await get_tree().create_timer(1.0).timeout

    _reset_actors()
    _run_intro()


func _stop_actors() -> void:
    _pacman.stop_moving()
    ghosts.stop_moving()
    ghost_mode.stop()


func _show_actors() -> void:
    _pacman.show()
    ghosts.show_all()


func _reset_actors() -> void:
    _pacman.reset_to_start_position()
    ghosts.reset_to_start_positions()


func _on_pellet_eaten(is_power_pellet: bool):
    var points := 50 if is_power_pellet else 10
    _update_current_player_score(points)
    ghosts.on_pellet_eaten()


func _on_all_pellets_eaten():
    print("Level Complete!")
    _state = State.GAME_OVER
    _stop_actors()


func _update_current_player_score(points: int) -> void:
    _scores[_current_player] += points
    var current_score := _scores[_current_player]
    scores_text.draw_player_score(_current_player, current_score)
    
    if current_score > _high_score:
        _high_score = current_score
        scores_text.draw_high_score(current_score)


# Factory methods to instantiate actors

func _make_pacman() -> PacMan:
    var pacman: PacMan = pacman_scene.instantiate()
    pacman.global_position = maze.get_pacman_start_position()
    pacman.maze = maze
    pacman.pellets = pellets
    pacman.hide()
    return pacman    


func _make_blinky() -> Ghost:
    var ghost: Ghost = ghost_scene.instantiate()
    ghost.name = "Blinky"
    ghost.animations = BLINKY_FRAMES
    ghost.global_position = maze.get_blinky_start_position()
    ghost.chase_target = _get_blinky_chase_target
    ghost.scatter_target = Vector2i(25, 0)
    ghost.state = Ghost.State.ACTIVE
    ghost.maze = maze
    ghost.ghost_mode = ghost_mode
    ghost.hide()
    return ghost


func _make_pinky() -> Ghost:
    var ghost: Ghost = ghost_scene.instantiate()
    ghost.name = "Pinky"
    ghost.animations = PINKY_FRAMES
    ghost.global_position = maze.get_pinky_start_position()
    ghost.chase_target = _get_pinky_chase_target
    ghost.scatter_target = Vector2i(2, 0)
    ghost.state = Ghost.State.IN_HOUSE
    ghost.maze = maze
    ghost.ghost_mode = ghost_mode
    ghost.hide()
    return ghost


func _make_inky() -> Ghost:
    var ghost: Ghost = ghost_scene.instantiate()
    ghost.name = "Inky"
    ghost.animations = INKY_FRAMES
    ghost.global_position = maze.get_inky_start_position()
    ghost.chase_target = _get_inky_chase_target
    ghost.scatter_target = Vector2i(27, 34)
    ghost.state = Ghost.State.IN_HOUSE
    ghost.maze = maze
    ghost.ghost_mode = ghost_mode
    ghost.hide()
    return ghost


func _make_clyde() -> Ghost:
    var ghost: Ghost = ghost_scene.instantiate()
    ghost.name = "Clyde"
    ghost.animations = CLYDE_FRAMES
    ghost.global_position = maze.get_clyde_start_position()
    ghost.chase_target = _get_clyde_chase_target
    ghost.scatter_target = Vector2i(0, 34)
    ghost.state = Ghost.State.IN_HOUSE
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
