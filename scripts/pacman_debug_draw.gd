extends Node2D
## Highlights the cell that Pac-Man is currently occupying.
##
## Used to debug which cell the Pac-Man sprite is in.

@export var pacman: Node2D
@export var maze: TileMapLayer


func _process(_delta: float) -> void:
    queue_redraw()


func _draw() -> void:
    if pacman == null or maze == null:
        return

    var size := maze.tile_set.tile_size
    var cell: Vector2i = maze.local_to_map(pacman.position)
    var center_local: Vector2 = maze.map_to_local(cell)
    var top_left := center_local - size * 0.5
    draw_rect(Rect2(top_left, size), Color(1, 0, 0, 0.3), false, 2.0)
