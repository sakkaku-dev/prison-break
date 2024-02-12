extends Node2D

@onready var chest = $Chest
@onready var enemies = $Enemies
@onready var player = $Player
@onready var open_chest = $OpenChest

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
var current_cell: Cell

func _ready():
	GameManager.looted_chest.connect(func(): chest.play("open"))
	GameManager.killed_enemy.connect(_update_visuals)
	
	GameManager.cell_clicked.connect(set_cell)
	GameManager.cell_view_ready.emit()

func set_cell(cell: Cell):
	for dir in cell.doors:
		var door = cell.get_door(dir) as CellDoor
		for c in door.opened.get_connections():
			c.signal.disconnect(c.callable)
		for c in door.closed.get_connections():
			c.signal.disconnect(c.callable)
	
	if current_cell:
		current_cell.unhighlight()
	
	current_cell = cell
	current_cell.highlight()
	
	_update_visuals()
	
	for dir in door_node.keys():
		var cell_door = cell.get_door(dir)
		if cell_door:
			_add_door(cell_door, dir)
		else:
			_remove_door(dir)

func _update_visuals():
	player.visible = current_cell.has_player()
	chest.visible = current_cell.has_chest()
	open_chest.visible = current_cell.has_open_chest()
	var enemy_count = current_cell.get_enemy_count()
	for i in enemies.get_child_count():
		enemies.get_child(i).visible = i < enemy_count
	
func _remove_door(dir: Vector2):
	var tile_pos = tile_position[dir]
	var atlas = wall_tile_coord[dir]
	tile_map.set_cell(0, tile_pos, 2, atlas)
	door_node[dir].hide()
	
func _add_door(cell_door: CellDoor, dir: Vector2):
	var tile_pos = tile_position[dir]
	tile_map.set_cell(0, tile_pos, -1)
	
	var door = door_node[dir]
	door.show()
	
	if cell_door.is_open:
		door.open(true)
	else:
		door.close(true)
	
	cell_door.opened.connect(func(): door.open())
	cell_door.closed.connect(func(): door.close())
