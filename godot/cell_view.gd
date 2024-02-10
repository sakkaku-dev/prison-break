extends Node2D

@onready var tile_map = $TileMap
@onready var door_node = {
	Vector2.UP: $Top,
	Vector2.RIGHT: $Right,
	Vector2.LEFT: $Left,
	Vector2.DOWN: $Bot,
}

var tile_position = {
	Vector2.UP: Vector2i(0, -5),
	Vector2.RIGHT: Vector2i(7, -1),
	Vector2.LEFT: Vector2i(-7, -1),
	Vector2.DOWN: Vector2i(0, 3),
}

var wall_tile_coord = {
	Vector2.UP: Vector2i(5, 0),
	Vector2.RIGHT: Vector2i(9, 2),
	Vector2.LEFT: Vector2i(1, 2),
	Vector2.DOWN: Vector2i(5, 10),
}

var top_wall_atlas_coord = Vector2i(5, 0)
var lef_wall_atlas_coord = Vector2i(5, 0)

var current_cell: Cell

func _ready():
	GameManager.cell_clicked.connect(set_cell)
	GameManager.cell_view_ready.emit()

func set_cell(cell: Cell):
	current_cell = cell
	for dir in door_node.keys():
		if cell.get_door(dir):
			_add_door(dir)
		else:
			_remove_door(dir)

func _remove_door(dir: Vector2):
	var tile_pos = tile_position[dir]
	var atlas = wall_tile_coord[dir]
	tile_map.set_cell(1, tile_pos, 2, atlas)
	door_node[dir].hide()
	
func _add_door(dir: Vector2):
	var tile_pos = tile_position[dir]
	tile_map.set_cell(1, tile_pos, -1)
	door_node[dir].show()
