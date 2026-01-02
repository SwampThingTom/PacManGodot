class_name ScoresRenderer
extends TileMapLayer
## Renders the scores for each player as well as the high score.

# Number of digits of score to show (always least significant)
const SIGNIFICANT_DIGITS: int = 6

const FONT_SOURCE_ID: int = 0

const DIGIT_ATLAS_COORDS: Array[Vector2i] = [
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

const P1_SCORE_ORIGIN: Vector2i = Vector2i(1, 1)
const P2_SCORE_ORIGIN: Vector2i = Vector2i(20, 1)
const HIGH_SCORE_ORIGIN: Vector2i = Vector2i(11, 1)


func clear_player_score(player_index: int) -> void:
    var origin := P1_SCORE_ORIGIN if player_index == 0 else P2_SCORE_ORIGIN
    _clear_score_at(origin)


func draw_player_score(player_index: int, score: int) -> void:
    var origin := P1_SCORE_ORIGIN if player_index == 0 else P2_SCORE_ORIGIN
    _draw_score_at(origin, score)


func draw_high_score(score: int) -> void:
    _draw_score_at(HIGH_SCORE_ORIGIN, score)

    
func _clear_score_at(origin: Vector2i) -> void:
    for i in range(SIGNIFICANT_DIGITS - 2):
        var cell := origin + Vector2i(i, 0)
        erase_cell(cell)

    var zero := DIGIT_ATLAS_COORDS[0]
    set_cell(origin + Vector2i(SIGNIFICANT_DIGITS - 2, 0), FONT_SOURCE_ID, zero)
    set_cell(origin + Vector2i(SIGNIFICANT_DIGITS - 1, 0), FONT_SOURCE_ID, zero)


func _draw_score_at(origin: Vector2i, score: int) -> void:
    # Pac-Man only shows 6 digits of score and the lsd is always 0
    var clamped_score: int = (score % 1_000_000) / 10
    var cell := origin + Vector2i(SIGNIFICANT_DIGITS - 2, 0)
    while clamped_score > 0:
        var digit := clamped_score % 10
        set_cell(cell, FONT_SOURCE_ID, DIGIT_ATLAS_COORDS[digit])
        clamped_score /= 10
        cell.x -= 1
