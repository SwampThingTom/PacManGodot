extends Node2D

@onready var maze := $Maze
@onready var pellets := $Pellets

func _ready():
	_center_maze()

func _center_maze():
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size / scale
	var tile_size: Vector2 = Vector2(maze.tile_set.tile_size)

	var used: Rect2i = maze.get_used_rect()
	var maze_size: Vector2 = tile_size * Vector2(used.size)

	var desired_top_left: Vector2 = (viewport_size - maze_size) / 2.0
	var offset_from_origin: Vector2 = tile_size * Vector2(used.position)
	maze.position = desired_top_left - offset_from_origin
	pellets.position = maze.position
