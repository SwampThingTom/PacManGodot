extends Node2D
## Manages the title screen.

const GAME_SCENE_PATH := "res://scenes/game.tscn"


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("start_game"):
        get_tree().change_scene_to_file(GAME_SCENE_PATH)
