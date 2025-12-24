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
        GameLevel.new(0.80, 0.90), # 1
        GameLevel.new(0.90, 0.95), # 2
        GameLevel.new(0.90, 0.95), # 3
        GameLevel.new(0.90, 0.95), # 4
        GameLevel.new(1.00, 1.00), # 5
        GameLevel.new(1.00, 1.00), # 6
        GameLevel.new(1.00, 1.00), # 7'
        GameLevel.new(1.00, 1.00), # 8
        GameLevel.new(1.00, 1.00), # 9
        GameLevel.new(1.00, 1.00), # 10
        GameLevel.new(1.00, 1.00), # 11
        GameLevel.new(1.00, 1.00), # 12
        GameLevel.new(1.00, 1.00), # 13
        GameLevel.new(1.00, 1.00), # 14
        GameLevel.new(1.00, 1.00), # 15
        GameLevel.new(1.00, 1.00), # 16
        GameLevel.new(1.00, 1.00), # 17
        GameLevel.new(1.00, 1.00), # 18
        GameLevel.new(1.00, 1.00), # 19
        GameLevel.new(1.00, 1.00), # 20
        GameLevel.new(0.90, 0.90), # 21+
    ]


static func get_pacman_norm_speed_pixels(level: int) -> float:
    return get_pacman_normal_speed_tiles(level) * TILE_SIZE


static func get_pacman_fright_speed_pixels(level: int) -> float:
    return get_pacman_fright_speed_tiles(level) * TILE_SIZE


static func get_pacman_normal_speed_tiles(level: int) -> float:
    var data := _get_level_data(level)
    return data.pacman_normal_speed_mult * MAX_TILES_PER_SECOND


static func get_pacman_fright_speed_tiles(level: int) -> float:
    var data := _get_level_data(level)
    return data.pacman_fright_speed_mult * MAX_TILES_PER_SECOND


static func _get_level_data(level: int) -> GameLevel:
    return _levels[_get_level_index(level)]


static func _get_level_index(level: int) -> int:
    assert(level > 0, "Level must be 1 or greater.")
    return min(level, MAX_DEFINED_LEVEL) - 1
