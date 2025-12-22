extends Node2D

const GAME_SCENE_PATH := "res://scenes/Game.tscn"

@onready var text := $Text

func _ready():
	_center_maze()

func _center_maze():
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size / scale
	var tile_size: Vector2 = Vector2(text.tile_set.tile_size)

	var used: Rect2i = text.get_used_rect()
	var maze_size: Vector2 = tile_size * Vector2(used.size)

	var desired_top_left: Vector2 = (viewport_size - maze_size) / 2.0
	var offset_from_origin: Vector2 = tile_size * Vector2(used.position)
	text.position = desired_top_left - offset_from_origin

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start_game"):
		get_tree().change_scene_to_file(GAME_SCENE_PATH)
