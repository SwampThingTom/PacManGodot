class_name LevelData
## Global level data for Pac-Man.
##
## Provides the GameLevel values for each level of the game.
## Note that levels after 21 use the same values as level 21.

# Actor max speed in pixels/second.
const MAX_PIXELS_PER_SECOND: float = 60.0

# Apply a scaling factor to the speed.
# TODO: Understand why this is needed and try to remove it.
const SCALED_MAX_PIXELS_PER_SECOND: float = MAX_PIXELS_PER_SECOND * 2.438

# Levels beyond this reuse the last entry.
const MAX_DEFINED_LEVEL: int = 21

# Index 0 = level 1, index 1 = level 2, ..., index 20 = level 21+.
static var _levels: Array[GameLevel] = []


# The speed values in this table are pixels moved per 32 frames.
# The arcade game used 32-bit values that were rotated every frame. If the
# 16th bit of the value was set, the actor moved 1 pixel. Otherwise it did
# not move. For now we will just use this to determine a fractional number
# of pixels to move each frame.
# TODO: Implement actual movement values from arcade game.
static func _static_init() -> void:
    _levels = [
        #             fruit       score  pn  pf  gn  gt  gf e1s e2s  e1p e2p fsec  b
        GameLevel.new("cherries",   100, 14, 16, 12,  4,  8, 13, 14,  20, 10, 6.0, 5),  # 1
        GameLevel.new("strawberry", 300, 18, 18, 16,  7,  9, 17, 18,  30, 15, 5.0, 5),  # 2
        GameLevel.new("peach",      500, 18, 18, 16,  7,  9, 17, 18,  40, 20, 4.0, 5),  # 3
        GameLevel.new("peach",      500, 18, 18, 16,  7,  9, 17, 18,  40, 20, 3.0, 5),  # 4
        GameLevel.new("apple",      700, 20, 20, 19, 10, 10, 20, 21,  40, 20, 2.0, 5),  # 5
        GameLevel.new("apple",      700, 20, 20, 19, 10, 10, 20, 21,  50, 25, 5.0, 5),  # 6
        GameLevel.new("grapes",    1000, 20, 20, 19, 10, 10, 20, 21,  50, 25, 2.0, 5),  # 7'
        GameLevel.new("grapes",    1000, 20, 20, 19, 10, 10, 20, 21,  50, 25, 2.0, 5),  # 8
        GameLevel.new("galaxian",  2000, 20, 20, 19, 10, 10, 20, 21,  60, 30, 1.0, 3),  # 9
        GameLevel.new("galaxian",  2000, 20, 20, 19, 10, 10, 20, 21,  60, 30, 5.0, 5),  # 10
        GameLevel.new("bell",      3000, 20, 20, 19, 10, 10, 20, 21,  60, 30, 2.0, 5),  # 11
        GameLevel.new("bell",      3000, 20, 20, 19, 10, 10, 20, 21,  80, 40, 1.0, 3),  # 12
        GameLevel.new("key",       5000, 20, 20, 19, 10, 10, 20, 21,  80, 40, 1.0, 3),  # 13
        GameLevel.new("key",       5000, 20, 20, 19, 10, 10, 20, 21,  80, 40, 3.0, 5),  # 14
        GameLevel.new("key",       5000, 20, 20, 19, 10, 10, 20, 21, 100, 50, 1.0, 3),  # 15
        GameLevel.new("key",       5000, 20, 20, 19, 10, 10, 20, 21, 100, 50, 1.0, 3),  # 16
        GameLevel.new("key",       5000, 20, 20, 19, 10, 10, 20, 21, 100, 50, 0.0, 0),  # 17
        GameLevel.new("key",       5000, 20, 20, 19, 10, 10, 20, 21, 100, 50, 1.0, 3),  # 18
        GameLevel.new("key",       5000, 20, 20, 19, 10, 10, 20, 21, 120, 60, 0.0, 0),  # 19
        GameLevel.new("key",       5000, 20, 20, 19, 10, 10, 20, 21, 120, 60, 0.0, 0),  # 20
        GameLevel.new("key",       5000, 18, 20, 19, 10, 10, 20, 21, 120, 60, 0.0, 0),  # 21+
    ]


static func get_fruit_name(level: int) -> String:
    var data := _get_level_data(level)
    return data.fruit_name


static func get_fruit_points(level: int) -> int:
    var data := _get_level_data(level)
    return data.fruit_points


static func get_pacman_normal_speed_pixels(level: int) -> float:
    var data := _get_level_data(level)
    return data.pacman_normal_speed_mult * SCALED_MAX_PIXELS_PER_SECOND


static func get_pacman_fright_speed_pixels(level: int) -> float:
    var data := _get_level_data(level)
    return data.pacman_fright_speed_mult * SCALED_MAX_PIXELS_PER_SECOND


static func get_ghost_normal_speed_pixels(level: int) -> float:
    var data := _get_level_data(level)
    return data.ghost_normal_speed_mult * SCALED_MAX_PIXELS_PER_SECOND


static func get_ghost_tunnel_speed_pixels(level: int) -> float:
    var data := _get_level_data(level)
    return data.ghost_tunnel_speed_mult * SCALED_MAX_PIXELS_PER_SECOND


static func get_ghost_fright_speed_pixels(level: int) -> float:
    var data := _get_level_data(level)
    return data.ghost_fright_speed_mult * SCALED_MAX_PIXELS_PER_SECOND


static func get_elroy_1_speed_pixels(level: int) -> float:
    var data := _get_level_data(level)
    return data.elroy_1_speed_mult * SCALED_MAX_PIXELS_PER_SECOND


static func get_elroy_2_speed_pixels(level: int) -> float:
    var data := _get_level_data(level)
    return data.elroy_2_speed_mult * SCALED_MAX_PIXELS_PER_SECOND


# A dead ghost returning to the ghost house uses the same speed regardless of level.
static func get_ghost_eyes_speed_pixels() -> float:
    return SCALED_MAX_PIXELS_PER_SECOND


static func get_elroy_1_dots(level: int) -> float:
    var data := _get_level_data(level)
    return data.elroy_1_dots


static func get_elroy_2_dots(level: int) -> float:
    var data := _get_level_data(level)
    return data.elroy_2_dots
    

static func get_fright_time_seconds(level: int) -> float:
    var data := _get_level_data(level)
    return data.fright_time_seconds


static func get_fright_flashes(level: int) -> int:
    var data := _get_level_data(level)
    return data.fright_flashes


static func _get_level_data(level: int) -> GameLevel:
    return _levels[_get_level_index(level)]


static func _get_level_index(level: int) -> int:
    assert(level > 0, "Level must be 1 or greater.")
    return min(level, MAX_DEFINED_LEVEL) - 1


## Configurable values for a specific level.
##
## Defines values such as the fruit available on a level, number of points the
## fruit is worth, speeds for Pac-Man and ghosts, frightened duration, etc.
class GameLevel:

    # The bonus fruit and points value.
    var fruit_name: String
    var fruit_points: int

    # These are *multipliers* relative to MAX_PIXELS_PER_SECOND.
    # e.g. pacman_normal_speed_mult = 0.80 means 80% of max speed.
    var pacman_normal_speed_mult: float
    var pacman_fright_speed_mult: float
    var ghost_normal_speed_mult: float
    var ghost_tunnel_speed_mult: float
    var ghost_fright_speed_mult: float
    var elroy_1_speed_mult: float
    var elroy_2_speed_mult: float
    
    # The number of dots remaining before Blinky gets faster.
    var elroy_1_dots: int
    var elroy_2_dots: int

    # How long frightened mode lasts.
    var fright_time_seconds: float
    var fright_flashes: int

    func _init(
        fruit_name: String,
        fruit_points: int,
        pacman_normal_speed_ratio: int,
        pacman_fright_speed_ratio: int,
        ghost_normal_speed_ratio: int,
        ghost_tunnel_speed_ratio: int,
        ghost_fright_speed_ratio: int,
        elroy_1_speed_ratio: int,
        elroy_2_speed_ratio: int,
        elroy_1_dots: int,
        elroy_2_dots: int,
        fright_time_seconds: float,
        fright_flashes: int,
    ) -> void:
        self.fruit_name = fruit_name
        self.fruit_points = fruit_points
        self.pacman_normal_speed_mult = float(pacman_normal_speed_ratio) / 32.0
        self.pacman_fright_speed_mult = float(pacman_fright_speed_ratio) / 32.0
        self.ghost_normal_speed_mult = float(ghost_normal_speed_ratio) / 32.0
        self.ghost_tunnel_speed_mult = float(ghost_tunnel_speed_ratio) / 32.0
        self.ghost_fright_speed_mult = float(ghost_fright_speed_ratio) / 32.0
        self.elroy_1_speed_mult = float(elroy_1_speed_ratio) / 32.0
        self.elroy_2_speed_mult = float(elroy_2_speed_ratio) / 32.0
        self.elroy_1_dots = elroy_1_dots
        self.elroy_2_dots = elroy_2_dots
        self.fright_time_seconds = fright_time_seconds
        self.fright_flashes = fright_flashes
