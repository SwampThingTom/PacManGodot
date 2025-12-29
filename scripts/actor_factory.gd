class_name ActorFactory
extends RefCounted
## Creates instances of game actors (Pac-Man and ghosts).

const PACMAN_SCENE  := preload("res://scenes/pacman.tscn")
const GHOST_SCENE   := preload("res://scenes/ghost.tscn")
const BLINKY_FRAMES := preload("res://resources/blinky.tres")
const PINKY_FRAMES  := preload("res://resources/pinky.tres")
const INKY_FRAMES   := preload("res://resources/inky.tres")
const CLYDE_FRAMES  := preload("res://resources/clyde.tres")
const FRIGHT_FRAMES := preload("res://resources/frightened.tres")

var _maze: Maze


func _init(maze: Maze) -> void:
    _maze = maze


func make_pacman(pellets: Pellets) -> PacMan:
    var pacman: PacMan = PACMAN_SCENE.instantiate()
    pacman.maze = _maze
    pacman.pellets = pellets
    pacman.hide()
    return pacman    


func make_blinky(ghost_mode: GhostMode, targeting: GhostTargeting) -> Ghost:
    var ghost: Ghost = GHOST_SCENE.instantiate()
    ghost.name = "Blinky"
    ghost.animations = BLINKY_FRAMES
    ghost.frightened_animations = FRIGHT_FRAMES
    ghost.chase_target = targeting.blinky_chase_target
    ghost.scatter_target = _maze.get_blinky_scatter_target()
    ghost.maze = _maze
    ghost.ghost_mode = ghost_mode
    ghost.hide()
    return ghost


func make_pinky(ghost_mode: GhostMode, targeting: GhostTargeting) -> Ghost:
    var ghost: Ghost = GHOST_SCENE.instantiate()
    ghost.name = "Pinky"
    ghost.animations = PINKY_FRAMES
    ghost.frightened_animations = FRIGHT_FRAMES
    ghost.chase_target = targeting.pinky_chase_target
    ghost.scatter_target = _maze.get_pinky_scatter_target()
    ghost.maze = _maze
    ghost.ghost_mode = ghost_mode
    ghost.hide()
    return ghost


func make_inky(ghost_mode: GhostMode, targeting: GhostTargeting) -> Ghost:
    var ghost: Ghost = GHOST_SCENE.instantiate()
    ghost.name = "Inky"
    ghost.animations = INKY_FRAMES
    ghost.frightened_animations = FRIGHT_FRAMES
    ghost.chase_target = targeting.inky_chase_target
    ghost.scatter_target = _maze.get_inky_scatter_target()
    ghost.maze = _maze
    ghost.ghost_mode = ghost_mode
    ghost.hide()
    return ghost


func make_clyde(ghost_mode: GhostMode, targeting: GhostTargeting) -> Ghost:
    var ghost: Ghost = GHOST_SCENE.instantiate()
    ghost.name = "Clyde"
    ghost.animations = CLYDE_FRAMES
    ghost.frightened_animations = FRIGHT_FRAMES
    ghost.chase_target = targeting.clyde_chase_target
    ghost.scatter_target = _maze.get_clyde_scatter_target()
    ghost.maze = _maze
    ghost.ghost_mode = ghost_mode
    ghost.hide()
    return ghost
