class_name GameLevel

# These are *multipliers* relative to MAX_TILES_PER_SECOND.
# e.g. pacman_norm_mult = 0.80 means 80% of max speed.
var pacman_normal_speed_mult: float
var pacman_fright_speed_mult: float

func _init(
    pacman_normal_speed_mult: float,
    pacman_fright_speed_mult: float
) -> void:
    self.pacman_normal_speed_mult = pacman_normal_speed_mult
    self.pacman_fright_speed_mult = pacman_fright_speed_mult
