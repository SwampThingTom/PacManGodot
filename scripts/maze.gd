class_name Maze
extends TileMapLayer
## Provides pathfinding data for navigating the maze.

var _min_x_cell: int = 0
var _max_x_cell: int = 0

var _tunnel_min_x: int = 0
var _tunnel_max_x: int = 0


func _ready():
    _calculate_tunnel_coordinates()


func get_cell(pos: Vector2) -> Vector2i:
    return local_to_map(pos)


func get_center_of_cell(cell: Vector2i) -> Vector2:
    return map_to_local(cell)


func is_open(cell: Vector2i, dir: Vector2i) -> bool:
    var next_cell: Vector2i = cell + dir
    return get_cell_tile_data(next_cell) == null


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

    var half_tile := tile_set.tile_size.x * 0.5
    _tunnel_min_x = map_to_local(Vector2i(_min_x_cell, 0)).x - half_tile
    _tunnel_max_x = map_to_local(Vector2i(_max_x_cell, 0)).x + half_tile
