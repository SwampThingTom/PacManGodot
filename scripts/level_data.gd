class_name LevelData
## Global level data for Pac-Man.
##
## Provides the GameLevel values for each level of the game.
## Note that levels after 21 use the same values as level 21.

# Tile size in pixels (original arcade uses 8x8 tiles).
const TILE_SIZE: float = 8.0

# Pac-Man max speed in tiles/second. (TODO: What did the original use?)
const MAX_TILES_PER_SECOND: float = 9.47

# Levels beyond this reuse the last entry.
const MAX_DEFINED_LEVEL: int = 21

# Index 0 = level 1, index 1 = level 2, ..., index 20 = level 21+.
static var _levels: Array[GameLevel] = []


static func _static_init() -> void:
    _levels = [
        GameLevel.new("cherries",   100, 0.80, 0.90, 0.75, 0.40, 0.50, 6.0, 5,  20, 0.80, 10, 0.85), # 1
        GameLevel.new("strawberry", 300, 0.90, 0.95, 0.85, 0.45, 0.55, 5.0, 5,  30, 0.90, 15, 0.95), # 2
        GameLevel.new("peach",      500, 0.90, 0.95, 0.85, 0.45, 0.55, 4.0, 5,  40, 0.90, 20, 0.95), # 3
        GameLevel.new("peach",      500, 0.90, 0.95, 0.85, 0.45, 0.55, 3.0, 5,  40, 0.90, 20, 0.95), # 4
        GameLevel.new("apple",      700, 1.00, 1.00, 0.95, 0.50, 0.60, 2.0, 5,  40, 1.00, 20, 1.05), # 5
        GameLevel.new("apple",      700, 1.00, 1.00, 0.95, 0.50, 0.60, 5.0, 5,  50, 1.00, 25, 1.05), # 6
        GameLevel.new("grapes",    1000, 1.00, 1.00, 0.95, 0.50, 0.60, 2.0, 5,  50, 1.00, 25, 1.05), # 7'
        GameLevel.new("grapes",    1000, 1.00, 1.00, 0.95, 0.50, 0.60, 2.0, 5,  50, 1.00, 25, 1.05), # 8
        GameLevel.new("galaxian",  2000, 1.00, 1.00, 0.95, 0.50, 0.60, 1.0, 3,  60, 1.00, 30, 1.05), # 9
        GameLevel.new("galaxian",  2000, 1.00, 1.00, 0.95, 0.50, 0.60, 5.0, 5,  60, 1.00, 30, 1.05), # 10
        GameLevel.new("bell",      3000, 1.00, 1.00, 0.95, 0.50, 0.60, 2.0, 5,  60, 1.00, 30, 1.05), # 11
        GameLevel.new("bell",      3000, 1.00, 1.00, 0.95, 0.50, 0.60, 1.0, 3,  80, 1.00, 40, 1.05), # 12
        GameLevel.new("key",       5000, 1.00, 1.00, 0.95, 0.50, 0.60, 1.0, 3,  80, 1.00, 40, 1.05), # 13
        GameLevel.new("key",       5000, 1.00, 1.00, 0.95, 0.50, 0.60, 3.0, 5,  80, 1.00, 40, 1.05), # 14
        GameLevel.new("key",       5000, 1.00, 1.00, 0.95, 0.50, 0.60, 1.0, 3, 100, 1.00, 50, 1.05), # 15
        GameLevel.new("key",       5000, 1.00, 1.00, 0.95, 0.50, 0.60, 1.0, 3, 100, 1.00, 50, 1.05), # 16
        GameLevel.new("key",       5000, 1.00, 1.00, 0.95, 0.50, 0.60, 0.0, 0, 100, 1.00, 50, 1.05), # 17
        GameLevel.new("key",       5000, 1.00, 1.00, 0.95, 0.50, 0.60, 1.0, 3, 100, 1.00, 50, 1.05), # 18
        GameLevel.new("key",       5000, 1.00, 1.00, 0.95, 0.50, 0.60, 0.0, 0, 120, 1.00, 60, 1.05), # 19
        GameLevel.new("key",       5000, 1.00, 1.00, 0.95, 0.50, 0.60, 0.0, 0, 120, 1.00, 60, 1.05), # 20
        GameLevel.new("key",       5000, 0.90, 0.90, 0.95, 0.50, 0.60, 0.0, 0, 120, 1.00, 60, 1.05), # 21+
    ]


static func get_fruit_name(level: int) -> String:
    var data := _get_level_data(level)
    return data.fruit_name


static func get_fruit_points(level: int) -> int:
    var data := _get_level_data(level)
    return data.fruit_points


static func get_pacman_normal_speed_pixels(level: int) -> float:
    return get_pacman_normal_speed_tiles(level) * TILE_SIZE


static func get_pacman_fright_speed_pixels(level: int) -> float:
    return get_pacman_fright_speed_tiles(level) * TILE_SIZE


static func get_ghost_normal_speed_pixels(level: int) -> float:
    return get_ghost_normal_speed_tiles(level) * TILE_SIZE


static func get_ghost_tunnel_speed_pixels(level: int) -> float:
    return get_ghost_tunnel_speed_tiles(level) * TILE_SIZE


static func get_ghost_fright_speed_pixels(level: int) -> float:
    return get_ghost_fright_speed_tiles(level) * TILE_SIZE


static func get_elroy_1_speed_pixels(level: int) -> float:
    return get_elroy_1_speed_tiles(level) * TILE_SIZE


static func get_elroy_2_speed_pixels(level: int) -> float:
    return get_elroy_2_speed_tiles(level) * TILE_SIZE


# A dead ghost returning to the ghost house uses the same speed regardless of level.
static func get_ghost_eyes_speed_pixels() -> float:
    return get_ghost_eyes_speed_tiles() * TILE_SIZE


static func get_pacman_normal_speed_tiles(level: int) -> float:
    var data := _get_level_data(level)
    return data.pacman_normal_speed_mult * MAX_TILES_PER_SECOND


static func get_pacman_fright_speed_tiles(level: int) -> float:
    var data := _get_level_data(level)
    return data.pacman_fright_speed_mult * MAX_TILES_PER_SECOND


static func get_ghost_normal_speed_tiles(level: int) -> float:
    var data := _get_level_data(level)
    return data.ghost_normal_speed_mult * MAX_TILES_PER_SECOND


static func get_ghost_tunnel_speed_tiles(level: int) -> float:
    var data := _get_level_data(level)
    return data.ghost_tunnel_speed_mult * MAX_TILES_PER_SECOND


static func get_ghost_fright_speed_tiles(level: int) -> float:
    var data := _get_level_data(level)
    return data.ghost_fright_speed_mult * MAX_TILES_PER_SECOND


# A dead ghost returning to the ghost house uses the same speed regardless of level.
static func get_ghost_eyes_speed_tiles() -> float:
    return MAX_TILES_PER_SECOND


static func get_elroy_1_speed_tiles(level: int) -> float:
    var data := _get_level_data(level)
    return data.elroy_1_speed_mult * MAX_TILES_PER_SECOND


static func get_elroy_2_speed_tiles(level: int) -> float:
    var data := _get_level_data(level)
    return data.elroy_2_speed_mult * MAX_TILES_PER_SECOND


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

    var fruit_name: String
    var fruit_points: int

    # These are *multipliers* relative to MAX_TILES_PER_SECOND.
    # e.g. pacman_normal_speed_mult = 0.80 means 80% of max speed.
    var pacman_normal_speed_mult: float
    var pacman_fright_speed_mult: float
    var ghost_normal_speed_mult: float
    var ghost_tunnel_speed_mult: float
    var ghost_fright_speed_mult: float

    var fright_time_seconds: float
    var fright_flashes: int
    
    var elroy_1_dots: float
    var elroy_1_speed_mult: float
    var elroy_2_dots: float
    var elroy_2_speed_mult: float

    func _init(
        fruit_name: String,
        fruit_points: int,
        pacman_normal_speed_mult: float,
        pacman_fright_speed_mult: float,
        ghost_normal_speed_mult: float,
        ghost_tunnel_speed_mult: float,
        ghost_fright_speed_mult: float,
        fright_time_seconds: float,
        fright_flashes: int,
        elroy_1_dots: float,
        elroy_1_speed_mult: float,
        elroy_2_dots: float,
        elroy_2_speed_mult: float
    ) -> void:
        self.fruit_name = fruit_name
        self.fruit_points = fruit_points
        self.pacman_normal_speed_mult = pacman_normal_speed_mult
        self.pacman_fright_speed_mult = pacman_fright_speed_mult
        self.ghost_normal_speed_mult = ghost_normal_speed_mult
        self.ghost_tunnel_speed_mult = ghost_tunnel_speed_mult
        self.ghost_fright_speed_mult = ghost_fright_speed_mult
        self.fright_time_seconds = fright_time_seconds
        self.fright_flashes = fright_flashes
        self.elroy_1_dots = elroy_1_dots
        self.elroy_1_speed_mult = elroy_1_speed_mult
        self.elroy_2_dots = elroy_2_dots
        self.elroy_2_speed_mult = elroy_2_speed_mult
