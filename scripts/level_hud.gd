class_name LevelHud
extends Node2D
## Manages the number of extra lives and the fruits displayed below the maze.

@onready var _life_sprites: Array[AnimatedSprite2D] = [
    $Life0, $Life1, $Life2
]

@onready var _fruit_sprites: Array[AnimatedSprite2D] = [
    $Fruit0, $Fruit1, $Fruit2, $Fruit3, $Fruit4, $Fruit5, $Fruit6
]


func update_lives(lives_remaining: int) -> void:
    assert(lives_remaining >= 0, "The player has negative lives remaining")
    for i in range(_life_sprites.size()):
        var sprite := _life_sprites[i]
        sprite.visible = i < lives_remaining


func update_fruits(level: int) -> void:
    var sprite_index: int = max(7 - level, 0)
    for i in range(sprite_index):
        _fruit_sprites[i].hide()
    
    while sprite_index < _fruit_sprites.size():
        var sprite := _fruit_sprites[sprite_index]
        sprite.animation = LevelData.get_fruit_name(level)
        sprite.show()
        level -= 1
        sprite_index += 1
