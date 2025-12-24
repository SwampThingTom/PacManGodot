# LevelData.gd
# Global level data for Pac-Man.
class_name LevelData

# Tile size in pixels (original arcade uses 8x8 tiles).
const TILE_SIZE: float = 8.0

# Pac-Man max speed in tiles/second. Original is ~10 tiles/s.
const MAX_TILES_PER_SECOND: float = 10.0

# Levels beyond this reuse the last entry.
const MAX_DEFINED_LEVEL: int = 21

# Index 0 = level 1, index 1 = level 2, ..., index 20 = level 21+.
static var _levels: Array[GameLevel] = []


static func _ensure_initialized() -> void:
    if not _levels.is_empty():
        return

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


static func _clamp_level(level: int) -> int:
    if level < 1:
        return 1
    if level > MAX_DEFINED_LEVEL:
        return MAX_DEFINED_LEVEL
    return level


static func _get_level_index(level: int) -> int:
    return _clamp_level(level) - 1


static func _get_level_data(level: int) -> GameLevel:
    _ensure_initialized()
    return _levels[_get_level_index(level)]


static func get_level_data(level: int) -> GameLevel:
    return _get_level_data(level)


static func get_pacman_normal_speed_tiles(level: int) -> float:
    var data := _get_level_data(level)
    return data.pacman_normal_speed_mult * MAX_TILES_PER_SECOND


static func get_pacman_fright_speed_tiles(level: int) -> float:
    var data := _get_level_data(level)
    return data.pacman_fright_speed_mult * MAX_TILES_PER_SECOND


static func get_pacman_norm_speed_pixels(level: int) -> float:
    return get_pacman_normal_speed_tiles(level) * TILE_SIZE


static func get_pacman_fright_speed_pixels(level: int) -> float:
    return get_pacman_fright_speed_tiles(level) * TILE_SIZE
