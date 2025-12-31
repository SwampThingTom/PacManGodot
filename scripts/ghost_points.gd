class_name GhostPoints
extends AnimatedSprite2D
# Renders the number of points scored for eating a ghost.

const SCORE_SPRITE := {
    200: "200",
    400: "400",
    800: "800",
    1600: "1600",
}


func show_points(points: int) -> void:
    animation = SCORE_SPRITE[points]
    visible = true
