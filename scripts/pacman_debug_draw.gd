extends Node2D

@export var pacman: Node2D
@export var maze: TileMapLayer

func _process(_delta: float) -> void:
    queue_redraw()

func _draw() -> void:
    if pacman == null or maze == null:
        return

    var size := maze.tile_set.tile_size
    var cell: Vector2i = maze.local_to_map(maze.to_local(pacman.global_position))
    var center_local: Vector2 = maze.map_to_local(cell)
    var top_left := maze.to_global(center_local - size * 0.5)
    draw_rect(Rect2(to_local(top_left), size), Color(1, 0, 0, 0.3), false, 2.0)
