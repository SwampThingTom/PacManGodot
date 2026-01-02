class_name Game
extends Node2D
## Manages a single Pac-Man game.
##
## Tracks number of players, current player, scores, lives, and level.

enum State {
    START_GAME,
    START_LEVEL,
    START_PLAYER,
    START_ROUND,
    PLAYING,
    PLAYER_DIED,
    LEVEL_COMPLETE,
    GAME_OVER,
}

const TITLE_SCENE_PATH := "res://scenes/title.tscn"
const PELLET_POINTS = 10
const POWER_PELLET_POINTS = 50
const INITIAL_GHOST_POINTS = 200
const GHOST_SCORE_FREEZE_SECONDS = 0.25
const EXTRA_LIFE_SCORE = 10_000

var _state: State = State.START_GAME
var _level: int = 1
var _show_start_player: bool
var _current_player: int = 0
var _lives_remaining: int = 2
var _was_extra_life_scored: bool = false
var _high_score: int = 0
var _scores: Array[int]
var _next_ghost_points: int = INITIAL_GHOST_POINTS
var _pacman: PacMan
var _targeting: GhostTargeting

@onready var maze: TileMapLayer = $Maze
@onready var pellets: Pellets = $Pellets
@onready var fruit: Fruit = $Fruit
@onready var player_one_text: TileMapLayer = $PlayerOneText
@onready var ready_text: TileMapLayer = $ReadyText
@onready var game_over_text: TileMapLayer = $GameOverText
@onready var scores_text: ScoresText = $ScoresText
@onready var level_hud: LevelHud = $LevelHud
@onready var ghost_mode: GhostMode = $GhostMode
@onready var ghosts: Ghosts = $Ghosts
@onready var ghost_points: GhostPoints = $GhostPoints
@onready var freeze_timer: Timer = $FreezeTimer # used while showing ghost points


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
        State.START_PLAYER:
            _start_player()
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
    _level = 1
    _show_start_player = true
    _spawn_actors()
    _connect_signals()
    _reset_scores()
    _transition_to(State.START_LEVEL)


func _start_level() -> void:
    print("START_LEVEL ", _level)
    level_hud.update_fruits(_level)
    pellets.reset_pellets()
    _pacman.on_start_level(_level)
    ghost_mode.on_start_level(_level)
    ghosts.on_start_level(_level)
    fruit.on_start_level(_level)
    if _show_start_player:
        _transition_to(State.START_PLAYER)
    else:
        _transition_to(State.START_ROUND)


func _start_player() -> void:
    print("START_PLAYER")
    _show_start_player = false
    await _show_start_player_sequence()
    _transition_to(State.START_ROUND)


func _start_round() -> void:
    print("START_ROUND")
    _pacman.on_start_round()
    ghost_mode.on_start_round()
    ghosts.on_start_round()
    fruit.on_start_round()
    await _show_ready_sequence()
    _transition_to(State.PLAYING)


func _playing() -> void:
    print("PLAYING")
    _pacman.on_playing()
    ghost_mode.on_playing()
    ghosts.on_playing()


func _player_died() -> void:
    print("PLAYER_DIED")
    _pacman.on_player_died()
    ghost_mode.on_player_died()
    ghosts.on_player_died()
    await _run_death_sequence()
    
    if _lives_remaining <= 0:
        _transition_to(State.GAME_OVER)
        return

    _lives_remaining -= 1
    _transition_to(State.START_ROUND)


func _level_complete() -> void:
    print("LEVEL_COMPLETE")
    _pacman.on_level_complete()
    ghost_mode.on_level_complete()
    ghosts.on_level_complete()
    await _run_level_complete_sequence()
    _level += 1
    _transition_to(State.START_LEVEL)


func _game_over() -> void:
    print("GAME_OVER")
    await _run_game_over_sequence()
    get_tree().change_scene_to_file(TITLE_SCENE_PATH)


# -----------------------------------------------
# Transition sequences
# -----------------------------------------------

func _show_start_player_sequence() -> void:
    player_one_text.show()
    ready_text.show()
    await get_tree().create_timer(2.0).timeout
    player_one_text.hide()

    
func _show_ready_sequence() -> void:
    ready_text.show()
    level_hud.update_lives(_lives_remaining)
    _pacman.show()
    ghosts.show_all()
    await get_tree().create_timer(1.6).timeout
    ready_text.hide()


func _run_death_sequence() -> void:
    await get_tree().create_timer(1.0).timeout
    ghosts.hide_all()
    await _pacman.play_death_animation()
    _pacman.hide()
    await get_tree().create_timer(1.0).timeout


func _run_level_complete_sequence() -> void:
    await get_tree().create_timer(1.0).timeout
    ghosts.hide_all()
    _pacman.hide()
    # TODO: blink map white
    await get_tree().create_timer(1.0).timeout


func _run_game_over_sequence() -> void:
    game_over_text.show()
    await get_tree().create_timer(5.0).timeout


# -----------------------------------------------
# Collision Detection
# -----------------------------------------------

func _check_collisions() -> void:
    # This assumes that all other nodes have already been processed this frame.
    # (i.e., process_priority of this node is larger than other nodes)
    _check_fruit_collision()
    _check_ghost_collisions()


func _check_fruit_collision() -> void:
    if not fruit.is_available():
        return
    if _pacman.position.distance_to(fruit.position) <= 8.0:
        _update_current_player_score(fruit.get_points())
        fruit.on_fruit_eaten()


func _check_ghost_collisions() -> void:
    var pacman_cell := _pacman.get_cell()
    for ghost in ghosts.get_ghosts():
        if not ghost.is_active():
            continue
        if ghost.get_cell() == pacman_cell:
            _on_collision(ghost)
            return


func _on_collision(ghost: Ghost) -> void:
    if ghost.is_frightened():
        _on_ghost_eaten(ghost)
    else:
        _transition_to(State.PLAYER_DIED)


# -----------------------------------------------
# Event Handlers
# -----------------------------------------------

func _on_pellet_eaten(is_power_pellet: bool, pellets_remaining: int):
    var points := POWER_PELLET_POINTS if is_power_pellet else PELLET_POINTS
    _update_current_player_score(points)
    ghosts.on_pellet_eaten(pellets_remaining)
    fruit.on_pellet_eaten()
    
    if is_power_pellet:
        _next_ghost_points = INITIAL_GHOST_POINTS
        ghost_mode.start_frightened()
    
    if pellets_remaining == 0:
        _transition_to(State.LEVEL_COMPLETE)


func _on_ghost_eaten(ghost: Ghost):
    _update_current_player_score(_next_ghost_points)
    await _show_ghost_points(ghost, _next_ghost_points)
    ghost.on_eaten()
    _next_ghost_points *= 2


# -----------------------------------------------
# Helpers
# -----------------------------------------------
   
func _reset_scores() -> void:
    _lives_remaining = 2
    _was_extra_life_scored = false
    _scores = [0, 0]
    scores_text.clear_player_score(0)


func _spawn_actors() -> void:
    assert(_pacman == null, "Actors already spawned")
    var actor_factory := ActorFactory.new(maze)

    _pacman = actor_factory.make_pacman(pellets)
    add_child(_pacman)

    _targeting = GhostTargeting.new(_pacman, ghosts, false)
    ghosts.on_start_game(
        actor_factory.make_blinky(ghost_mode, _targeting), 
        actor_factory.make_pinky(ghost_mode, _targeting), 
        actor_factory.make_inky(ghost_mode, _targeting), 
        actor_factory.make_clyde(ghost_mode, _targeting))


func _connect_signals() -> void:
    pellets.pellet_eaten.connect(_on_pellet_eaten)


func _update_current_player_score(points: int) -> void:
    _scores[_current_player] += points
    var current_score := _scores[_current_player]
    scores_text.draw_player_score(_current_player, current_score)
    
    if current_score > _high_score:
        _high_score = current_score
        scores_text.draw_high_score(current_score)
    
    if not _was_extra_life_scored and current_score >= EXTRA_LIFE_SCORE:
        _was_extra_life_scored = true
        _lives_remaining += 1
        level_hud.update_lives(_lives_remaining)


func _show_ghost_points(ghost: Ghost, points: int) -> void:
    _pacman.hide()
    ghost.hide()

    ghost_points.position = maze.get_center_of_cell(ghost.get_cell())
    ghost_points.show_points(points)
    await _freeze_game(GHOST_SCORE_FREEZE_SECONDS)
    ghost_points.hide()

    ghost.show()
    _pacman.show()


# Pauses game play briefly while ghost score is displayed.
func _freeze_game(seconds: float) -> void:
    get_tree().paused = true
    freeze_timer.start(seconds)
    await freeze_timer.timeout
    get_tree().paused = false
