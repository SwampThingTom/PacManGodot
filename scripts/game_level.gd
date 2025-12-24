class_name GameLevel
## Configurable values for a specific level.
##
## Defines values such as the fruit available on a level, number of points the
## fruit is worth, speeds for Pac-Man and ghosts, frightened duration, etc.

# These are *multipliers* relative to MAX_TILES_PER_SECOND.
# e.g. pacman_normal_speed_mult = 0.80 means 80% of max speed.
var pacman_normal_speed_mult: float
var pacman_fright_speed_mult: float

func _init(
    pacman_normal_speed_mult: float,
    pacman_fright_speed_mult: float
) -> void:
    self.pacman_normal_speed_mult = pacman_normal_speed_mult
    self.pacman_fright_speed_mult = pacman_fright_speed_mult
