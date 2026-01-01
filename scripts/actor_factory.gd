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
const FLASH_FRAMES  := preload("res://resources/flash.tres")
const EYES_FRAMES   := preload("res://resources/eyes.tres")

const Z_INDEX_PAC_MAN := 10
const Z_INDEX_GHOSTS  := 20

var _maze: Maze


func _init(maze: Maze) -> void:
    _maze = maze


func make_pacman(pellets: Pellets) -> PacMan:
    var pacman: PacMan = PACMAN_SCENE.instantiate()
    pacman.maze = _maze
    pacman.pellets = pellets
    pacman.z_index = Z_INDEX_PAC_MAN
    pacman.hide()
    return pacman    


func make_blinky(ghost_mode: GhostMode, targeting: GhostTargeting) -> Ghost:
    return _make_ghost(
        "Blinky",
        Ghosts.GhostId.BLINKY,
        BLINKY_FRAMES,
        targeting.blinky_chase_target,
        _maze.get_blinky_scatter_target(),
        ghost_mode)


func make_pinky(ghost_mode: GhostMode, targeting: GhostTargeting) -> Ghost:
    return _make_ghost(
        "Pinky",
        Ghosts.GhostId.PINKY,
        PINKY_FRAMES,
        targeting.pinky_chase_target,
        _maze.get_pinky_scatter_target(),
        ghost_mode)


func make_inky(ghost_mode: GhostMode, targeting: GhostTargeting) -> Ghost:
    return _make_ghost(
        "Inky",
        Ghosts.GhostId.INKY,
        INKY_FRAMES,
        targeting.inky_chase_target,
        _maze.get_inky_scatter_target(),
        ghost_mode)


func make_clyde(ghost_mode: GhostMode, targeting: GhostTargeting) -> Ghost:
    return _make_ghost(
        "Clyde",
        Ghosts.GhostId.CLYDE,
        CLYDE_FRAMES,
        targeting.clyde_chase_target,
        _maze.get_clyde_scatter_target(),
        ghost_mode)


func _make_ghost(
    name: String, 
    ghost_id: Ghosts.GhostId,
    animations: SpriteFrames, 
    chase_target: Callable, 
    scatter_target: Vector2i, 
    ghost_mode: GhostMode
) -> Ghost:
    var ghost: Ghost = GHOST_SCENE.instantiate()
    ghost.name = name
    ghost.ghost_id = ghost_id
    ghost.chase_target = chase_target
    ghost.scatter_target = scatter_target
    ghost.ghost_mode = ghost_mode
    ghost.normal_animations = animations
    ghost.frightened_animations = FRIGHT_FRAMES
    ghost.flash_animations = FLASH_FRAMES
    ghost.eyes_animations = EYES_FRAMES
    ghost.maze = _maze
    ghost.z_index = Z_INDEX_GHOSTS
    ghost.hide()
    return ghost
    
