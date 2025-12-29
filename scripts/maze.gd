class_name Maze
extends TileMapLayer
## Provides pathfinding data for navigating the maze.

# Ghosts can not move up from these cells
const SAFE_ZONE_CELLS: Array[Vector2i] = [
    Vector2i(12, 14), Vector2i(15, 14), Vector2i(12, 26), Vector2i(15, 26)
]

var _min_x_cell: int = 0
var _max_x_cell: int = 0

var _tunnel_min_x: int = 0
var _tunnel_max_x: int = 0

var _half_tile_size: int


func _ready():
    _half_tile_size = tile_set.tile_size.x / 2
    _calculate_tunnel_coordinates()


func get_cell(pos: Vector2) -> Vector2i:
    return local_to_map(pos)


func get_center_of_cell(cell: Vector2i) -> Vector2:
    return map_to_local(cell)


func is_open(cell: Vector2i, dir: Vector2i) -> bool:
    var next_cell: Vector2i = cell + dir
    return get_cell_tile_data(next_cell) == null


func is_safe_zone(cell: Vector2i) -> bool:
    return SAFE_ZONE_CELLS.has(cell)


func wrap_cell(cell: Vector2i) -> Vector2i:
    if cell.x < _min_x_cell:
        return Vector2i(_max_x_cell, cell.y)
    if cell.x > _max_x_cell:
        return Vector2i(_min_x_cell, cell.y)
    return cell


func is_in_tunnel(cell: Vector2i) -> bool:
    if cell.y != 17:
        return false
    if cell.x >= 6 and cell.x <= 21:
        return false
    return true


func handle_tunnel(pos: Vector2) -> Vector2:
    if pos.x < _tunnel_min_x:
        pos.x = _tunnel_max_x + pos.x - _tunnel_min_x
    elif pos.x > _tunnel_max_x:
        pos.x = _tunnel_min_x + pos.x - _tunnel_max_x
    return pos


func _calculate_tunnel_coordinates() -> void:
    var used := get_used_rect()
    _min_x_cell = used.position.x
    _max_x_cell = used.position.x + used.size.x - 1

    _tunnel_min_x = map_to_local(Vector2i(_min_x_cell, 0)).x - _half_tile_size
    _tunnel_max_x = map_to_local(Vector2i(_max_x_cell, 0)).x + _half_tile_size


func get_ghost_home_exit_position() -> Vector2:
    var pos: Vector2 = map_to_local(Vector2i(13, 14))
    pos.x += _half_tile_size
    return pos


func get_ghost_home_center_position() -> Vector2:
    var pos: Vector2 = map_to_local(Vector2i(13, 17))
    pos.x += _half_tile_size
    return pos


func get_ghost_home_left_position() -> Vector2:
    var pos: Vector2 = map_to_local(Vector2i(11, 17))
    pos.x += _half_tile_size
    return pos


func get_ghost_home_right_position() -> Vector2:
    var pos: Vector2 = map_to_local(Vector2i(15, 17))
    pos.x += _half_tile_size
    return pos


func get_pacman_start_position() -> Vector2:
    var pos: Vector2 = map_to_local(Vector2i(13, 26))
    pos.x += _half_tile_size
    return pos


func get_blinky_start_position() -> Vector2:
    return get_ghost_home_exit_position()


func get_pinky_start_position() -> Vector2:
    return get_ghost_home_center_position()


func get_inky_start_position() -> Vector2:
    return get_ghost_home_left_position()


func get_clyde_start_position() -> Vector2:
    return get_ghost_home_right_position()


func get_blinky_scatter_target() -> Vector2i:
    return Vector2i(25, 0)


func get_pinky_scatter_target() -> Vector2i:
    return Vector2i(2, 0)


func get_inky_scatter_target() -> Vector2i:
    return Vector2i(27, 34)


func get_clyde_scatter_target() -> Vector2i:
    return Vector2i(0, 34)
