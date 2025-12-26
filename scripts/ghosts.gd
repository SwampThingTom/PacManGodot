class_name Ghosts
extends Node2D
## Manages spawning ghosts and controlling when they release from their house.

func start_moving() -> void:
    for ghost in get_children():
        print(ghost.name)
        ghost.start_moving()
