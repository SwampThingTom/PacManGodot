class_name Pellets
extends TileMapLayer
## Manages the remaining pellets in the maze.

signal pellet_eaten(is_power_pellet: bool)
signal all_pellets_eaten

var pellets_remaining: int


func _ready() -> void:
    pellets_remaining = get_used_cells().size()


func try_eat_pellet(grid_pos: Vector2i) -> void:
    var tile_data := get_cell_tile_data(grid_pos)
    if tile_data == null:
        return
    
    set_cell(grid_pos, -1)
    pellets_remaining -= 1
    
    var is_power_pellet := _tile_has_power_pellet(tile_data)
    emit_signal("pellet_eaten", is_power_pellet)
    
    if pellets_remaining <= 0:
        emit_signal("all_pellets_eaten")


func _tile_has_power_pellet(tile_data: TileData) -> bool:
    if not tile_data.has_custom_data("is_power_pellet"):
        return false
    return tile_data.get_custom_data("is_power_pellet")
