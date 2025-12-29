class_name GameLevel
## Configurable values for a specific level.
##
## Defines values such as the fruit available on a level, number of points the
## fruit is worth, speeds for Pac-Man and ghosts, frightened duration, etc.

# These are *multipliers* relative to MAX_TILES_PER_SECOND.
# e.g. pacman_normal_speed_mult = 0.80 means 80% of max speed.
var pacman_normal_speed_mult: float
var pacman_fright_speed_mult: float
var ghost_normal_speed_mult: float
var ghost_tunnel_speed_mult: float
var ghost_fright_speed_mult: float
var fright_time_seconds: float
var fright_flashes: int

func _init(
    pacman_normal_speed_mult: float,
    pacman_fright_speed_mult: float,
    ghost_normal_speed_mult: float,
    ghost_tunnel_speed_mult: float,
    ghost_fright_speed_mult: float,
    fright_time_seconds: float,
    fright_flashes: int
) -> void:
    self.pacman_normal_speed_mult = pacman_normal_speed_mult
    self.pacman_fright_speed_mult = pacman_fright_speed_mult
    self.ghost_normal_speed_mult = ghost_normal_speed_mult
    self.ghost_tunnel_speed_mult = ghost_tunnel_speed_mult
    self.ghost_fright_speed_mult = ghost_fright_speed_mult
    self.fright_time_seconds = fright_time_seconds
    self.fright_flashes = fright_flashes
