class_name LevelData
## Global level data for Pac-Man.
##
## Provides the GameLevel values for each level of the game.
## Note that levels after 21 use the same values as level 21.

# Tile size in pixels (original arcade uses 8x8 tiles).
const TILE_SIZE: float = 8.0

# Pac-Man max speed in tiles/second. Original is ~10 tiles/s.
const MAX_TILES_PER_SECOND: float = 10.0

# Levels beyond this reuse the last entry.
const MAX_DEFINED_LEVEL: int = 21

# Index 0 = level 1, index 1 = level 2, ..., index 20 = level 21+.
static var _levels: Array[GameLevel] = []


static func _static_init() -> void:
    _levels = [
        GameLevel.new(0.80, 0.90, 0.75, 0.40, 0.50, 6.0, 5), # 1
        GameLevel.new(0.90, 0.95, 0.85, 0.45, 0.55, 5.0, 5), # 2
        GameLevel.new(0.90, 0.95, 0.85, 0.45, 0.55, 4.0, 5), # 3
        GameLevel.new(0.90, 0.95, 0.85, 0.45, 0.55, 3.0, 5), # 4
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 2.0, 5), # 5
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 5.0, 5), # 6
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 2.0, 5), # 7'
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 2.0, 5), # 8
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 1.0, 3), # 9
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 5.0, 5), # 10
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 2.0, 5), # 11
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 1.0, 3), # 12
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 1.0, 3), # 13
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 3.0, 5), # 14
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 1.0, 3), # 15
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 1.0, 3), # 16
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 0.0, 0), # 17
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 1.0, 3), # 18
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 0.0, 0), # 19
        GameLevel.new(1.00, 1.00, 0.95, 0.50, 0.60, 0.0, 0), # 20
        GameLevel.new(0.90, 0.90, 0.95, 0.50, 0.60, 0.0, 0), # 21+
    ]


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
