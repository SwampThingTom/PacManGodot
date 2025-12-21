extends Node2D

enum CellType {
	EMPTY,
	WALL,
	GHOST_DOOR,
	PELLET,
	SUPER_PELLET
}

const MAZE_DEFINITION := [
	"╔════════════╗╔════════════╗",
	"║............││............║",
	"║.┌──┐.┌───┐.││.┌───┐.┌──┐.║",
	"║o│  │.│   │.││.│   │.│  │o║",
	"║.└──┘.└───┘.└┘.└───┘.└──┘.║",
	"║..........................║",
	"║.┌──┐.┌┐.┌──────┐.┌┐.┌──┐.║",
	"║.└──┘.││.└──┐┌──┘.││.└──┘.║",
	"║......││....││....││......║",
	"╚════╗.│└--┐ ││ ┌--┘│.╔════╝",
	"     ║.│┌--┘ └┘ └--┐│.║     ",
	"     ║.││          ││.║     ",
	"     ║.││ ┏━━__━━┓ ││.║     ",
	"═════╝.└┘ ┃      ┃ └┘.╚═════",
	"      .   ┃      ┃   .      ",
	"═════╗.┌┐ ┃      ┃ ┌┐.╔═════",
	"     ║.││ ┗━━━━━━┛ ││.║     ",
	"     ║.││          ││.║     ",
	"     ║.││ ┌──────┐ ││.║     ",
	"╔════╝.└┘ └──┐┌──┘ └┘.╚════╗",
	"║............││............║",
	"║.┌──┐.┌───┐.││.┌───┐.┌──┐.║",
	"║.└─┐│.└───┘.└┘.└───┘.│┌─┘.║",
	"║o..││.......  .......││..o║",
	"╚─┐.││.┌┐.┌──────┐.┌┐.││.┌─╝",
	"╔─┘.└┘.││.└──┐┌──┘.││.└┘.└─╗",
	"║......││....││....││......║",
	"║.┌────┘└──┐.││.┌──┘└────┐.║",
	"║.└────────┘.└┘.└────────┘.║",
	"║..........................║",
	"╚══════════════════════════╝",
]

const OUTER_WALL_DOWN_RIGHT := "╔"
const OUTER_WALL_LEFT_DOWN := "╗"
const OUTER_WALL_UP_RIGHT := "╚"
const OUTER_WALL_LEFT_UP := "╝"
const OUTER_WALL_HORIZONTAL := "═"
const OUTER_WALL_VERTICAL := "║"

const INNER_WALL_DOWN_RIGHT := "┌"
const INNER_WALL_LEFT_DOWN := "┐"
const INNER_WALL_UP_RIGHT := "└"
const INNER_WALL_LEFT_UP := "┘"
const INNER_WALL_HORIZONTAL := "─"
const INNER_WALL_VERTICAL := "│"

const GHOST_WALL_TOP_LEFT := "┏"
const GHOST_WALL_TOP_RIGHT := "┓"
const GHOST_WALL_BOTTOM_LEFT := "┗"
const GHOST_WALL_BOTTOM_RIGHT := "┛"
const GHOST_WALL_VERTICAL := "┃"
const GHOST_WALL_HORIZONTAL := "━"

const GHOST_DOOR := "_"
const PELLET := "."
const POWER_PELLET := "o"
const EMPTY := ' '

const TEXTURE_SOURCE_ID := 0

const CHAR_TO_ATLAS: Dictionary = {
	# Outer walls (double)
	"╔": Vector2i(16, 3),
	"╗": Vector2i(19, 3),
	"╚": Vector2i(16, 6),
	"╝": Vector2i(19, 6),
	"═": Vector2i(17, 0),  # TODO: Doesn't seem right
	"║": Vector2i(16, 1),  # TODO: Doesn't seem right

	# Inner walls (single)
	"┌": Vector2i(16, 0),
	"┐": Vector2i(18, 0),
	"└": Vector2i(16, 2),
	"┘": Vector2i(18, 2),
	"─": Vector2i(17, 0),
	"│": Vector2i(16, 1),

	# Ghost walls (heavy)
	"┏": Vector2i(19, 0),
	"┓": Vector2i(21, 0),
	"┗": Vector2i(19, 2),
	"┛": Vector2i(21, 2),
	"━": Vector2i(4, 2),
	"┃": Vector2i(5, 2),

	# Ghost door
	"_": Vector2i(0, 3),
}

var maze : Array = []   # [y][x]

@onready var maze_tile_layer := $Maze

func build_maze():
	var layer := 0
	for y in range(MAZE_DEFINITION.size()):
		var row_str : String = MAZE_DEFINITION[y]
		for x in range(row_str.length()):
			var cell := Vector2i(x, y)
			var ch := row_str[x]

			var atlas: Variant = CHAR_TO_ATLAS.get(ch, null)
			if atlas == null:
				# No tile for this char (floor, pellet you draw elsewhere, etc.)
				maze_layer.set_cell(layer, cell, -1)
			else:
				maze_layer.set_cell(layer, cell, TEXTURE_SOURCE_ID, atlas)

func _pick_inner_wall_tile(cell: Vector2i) -> Vector2i:
	return Vector2i(0, 0)
	
func _pick_ghost_wall_tile(cell: Vector2i) -> Vector2i:
	return Vector2i(0, 0)

func _pick_ghost_door_tile() -> Vector2i:
	return Vector2i(0, 0)

func _ready():
	print("Game ready")
