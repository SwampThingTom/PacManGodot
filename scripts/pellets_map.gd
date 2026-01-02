class_name PelletsMap
extends TileMapLayer
## Manages the remaining pellets in the maze.

signal pellet_eaten(is_power_pellet: bool, pellets_remaining: int)

var pellets_remaining: int
var _snapshot: Array[Dictionary] = []


func _ready() -> void:
    _take_snapshot()


func reset_pellets() -> void:
    for entry in _snapshot:
        set_cell(
            entry["cell"],
            entry["source_id"],
            entry["atlas_coords"],
            entry["alternative"])
    pellets_remaining = get_used_cells().size()
    

func try_eat_pellet(grid_pos: Vector2i) -> void:
    var tile_data := get_cell_tile_data(grid_pos)
    if tile_data == null:
        return
    
    set_cell(grid_pos, -1)
    pellets_remaining -= 1
    
    var is_power_pellet := _tile_has_power_pellet(tile_data)
    emit_signal("pellet_eaten", is_power_pellet, pellets_remaining)


func _tile_has_power_pellet(tile_data: TileData) -> bool:
    if not tile_data.has_custom_data("is_power_pellet"):
        return false
    return tile_data.get_custom_data("is_power_pellet")


func _take_snapshot() -> void:
    for cell in get_used_cells():
        var td: TileData = get_cell_tile_data(cell)
        if td == null:
            continue
        _snapshot.append({
            "cell": cell,
            "source_id": get_cell_source_id(cell),
            "atlas_coords": get_cell_atlas_coords(cell),
            "alternative": get_cell_alternative_tile(cell),
        })
