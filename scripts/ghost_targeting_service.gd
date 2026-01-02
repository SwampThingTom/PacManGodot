class_name GhostTargetingService
extends RefCounted
## Determines chase mode targets for each ghost.

var pacman: PacManActor
var ghosts: GhostCoordinator

## If true, applies the original "Pinky/Inky up-direction bug".
var use_original_bugs: bool = false


func _init(pacman: PacManActor, ghosts: GhostCoordinator, use_original_bugs: bool = false) -> void:
    self.pacman = pacman
    self.ghosts = ghosts
    self.use_original_bugs = use_original_bugs


# -----------------------------------------------
# Chase Targets
# -----------------------------------------------

func blinky_chase_target() -> Vector2i:
    return pacman.get_cell()


func pinky_chase_target() -> Vector2i:
    return _ahead_of_pacman(4)


func inky_chase_target() -> Vector2i:
    var pivot: Vector2i = _ahead_of_pacman(2)
    var blinky: GhostActor = ghosts.get_ghost(GhostCoordinator.GhostId.BLINKY)
    var blinky_cell: Vector2i = blinky.get_cell()
    return blinky_cell + (pivot - blinky_cell) * 2


func clyde_chase_target() -> Vector2i:
    var clyde: GhostActor = ghosts.get_ghost(GhostCoordinator.GhostId.CLYDE)
    var distance := clyde.get_cell().distance_to(pacman.get_cell())
    return pacman.get_cell() if distance >= 8.0 else clyde.scatter_target


# -----------------------------------------------
# Helpers
# -----------------------------------------------

func _ahead_of_pacman(tiles: int) -> Vector2i:
    var cell := pacman.get_cell()
    var dir: Vector2i = pacman.get_direction()
    var target := cell + dir * tiles

    # Arcade quirk: when Pac-Man is facing up, the "ahead" target is offset left as well.
    if use_original_bugs and dir == Vector2i.UP:
        target += Vector2i.LEFT * tiles

    return target
