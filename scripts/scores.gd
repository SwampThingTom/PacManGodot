class_name ScoresText
extends TileMapLayer
## Renders the scores for each player as well as the high score.

const SIGNIFICANT_DIGITS: int = 6

@export var font_source_id: int = 0

@export var digit_atlas_coords: Array[Vector2i] = [
    Vector2i(0, 2), # 0
    Vector2i(1, 2), # 1
    Vector2i(2, 2), # 2
    Vector2i(3, 2), # 3
    Vector2i(4, 2), # 4
    Vector2i(5, 2), # 5
    Vector2i(6, 2), # 6
    Vector2i(7, 2), # 7
    Vector2i(8, 2), # 8
    Vector2i(9, 2), # 9
]

@export var p1_score_origin: Vector2i = Vector2i(1, 1)
@export var p2_score_origin: Vector2i = Vector2i(20, 1)
@export var high_score_origin: Vector2i = Vector2i(11, 1)


func clear_player_score(player_index: int) -> void:
    var origin := p1_score_origin if player_index == 0 else p2_score_origin
    _clear_score_at(origin)


func draw_player_score(player_index: int, score: int) -> void:
    var origin := p1_score_origin if player_index == 0 else p2_score_origin
    _draw_score_at(origin, score)


func draw_high_score(score: int) -> void:
    _draw_score_at(high_score_origin, score)

    
func _clear_score_at(origin: Vector2i) -> void:
    for i in range(SIGNIFICANT_DIGITS - 2):
        var cell := origin + Vector2i(i, 0)
        erase_cell(cell)

    var zero := digit_atlas_coords[0]
    set_cell(origin + Vector2i(SIGNIFICANT_DIGITS - 2, 0), font_source_id, zero)
    set_cell(origin + Vector2i(SIGNIFICANT_DIGITS - 1, 0), font_source_id, zero)


func _draw_score_at(origin: Vector2i, score: int) -> void:
    # Pac-Man only shows 6 digits of score and the lsd is always 0
    var clamped_score: int = (score % 1_000_000) / 10
    var cell := origin + Vector2i(SIGNIFICANT_DIGITS - 2, 0)
    while clamped_score > 0:
        var digit := clamped_score % 10
        set_cell(cell, font_source_id, digit_atlas_coords[digit])
        clamped_score /= 10
        cell.x -= 1
