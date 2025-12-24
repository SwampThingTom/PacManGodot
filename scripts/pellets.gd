extends TileMapLayer
class_name Pellets

signal power_pellet_eaten()

var pellets_remaining: int = 0

func _ready() -> void:
    pellets_remaining = _count_pellets()

func _count_pellets() -> int:
    var count := 0
    for cell in get_used_cells():
        count += 1
    return count

func did_eat_pellet(grid_pos: Vector2i) -> bool:
    var tile_data := get_cell_tile_data(grid_pos)
    if tile_data == null:
        return false

    set_cell(grid_pos, -1)
    pellets_remaining -= 1

    if _tile_has_power_pellet(tile_data):
        emit_signal("power_pellet_eaten")

    return true

func _tile_has_power_pellet(tile_data: TileData) -> bool:
    if not tile_data.has_custom_data("is_power_pellet"):
        return false
    return tile_data.get_custom_data("is_power_pellet")
