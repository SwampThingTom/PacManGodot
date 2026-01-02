class_name PelletsMap
extends TileMapLayer
## Manages the remaining pellets in the maze.

signal pellet_eaten(is_power_pellet: bool, pellets_remaining: int)

var _pellets_remaining: int
var _snapshot: Array[Dictionary] = []


func _ready() -> void:
    _take_snapshot()


func reset_pellets() -> void:
    for pellet in _snapshot:
        set_cell(
            pellet.cell,
            pellet.source_id,
            pellet.atlas_coords,
            pellet.alternative)
    _pellets_remaining = get_used_cells().size()


func get_pellets_remaining() -> int:
    return _pellets_remaining


func try_eat_pellet(grid_pos: Vector2i) -> void:
    var tile_data := get_cell_tile_data(grid_pos)
    if tile_data == null:
        return
    
    set_cell(grid_pos, -1)
    _pellets_remaining -= 1
    
    var is_power_pellet := _tile_has_power_pellet(tile_data)
    emit_signal("pellet_eaten", is_power_pellet, _pellets_remaining)


func _tile_has_power_pellet(tile_data: TileData) -> bool:
    if not tile_data.has_custom_data("is_power_pellet"):
        return false
    return tile_data.get_custom_data("is_power_pellet")


func _take_snapshot() -> void:
    for cell in get_used_cells():
        var td: TileData = get_cell_tile_data(cell)
        if td == null:
            continue
        _snapshot.append(PelletSnapshot.new(
            cell, 
            get_cell_source_id(cell),
            get_cell_atlas_coords(cell),
            get_cell_alternative_tile(cell)
        ))


class PelletSnapshot:
    var cell: Vector2i
    var source_id: int
    var atlas_coords: Vector2i
    var alternative: int
    
    func _init(cell: Vector2i, source_id: int, atlas_coords: Vector2i, alternative: int):
        self.cell = cell
        self.source_id = source_id
        self.atlas_coords = atlas_coords
        self.alternative = alternative
