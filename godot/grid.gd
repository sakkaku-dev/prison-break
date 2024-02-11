extends Node2D

@export var cell_scene: PackedScene
@export var door_scene: PackedScene
@export var cell_distance := Vector2(160, 120)
@export var grid_size := Vector2(5, 5)

var grid_data: Array[Array] = []
var first_room: Cell

func _ready():
	_create_map()

func _create_map():
	for c in get_children():
		remove_child(c)
		
	grid_data = []
	
	for y in grid_size.y:
		grid_data.append([])
		for x in grid_size.x:
			var coord = Vector2(x, y)
			var cell = _create_cell(coord)
			grid_data[y].append(cell)
			
			if y > 0:
				var above_cell = grid_data[y - 1][x]
				var above_door = above_cell.get_door(Vector2.DOWN)
				if above_door:
					cell.add_door(Vector2.UP, above_door)
			
			if x > 0:
				var left_cell = grid_data[y][x - 1]
				var left_door = left_cell.get_door(Vector2.RIGHT)
				if left_door:
					cell.add_door(Vector2.LEFT, left_door)
			
			_create_missing_doors(cell, coord)
			add_child(cell)
	
	if GameManager.level <= 0:
		_create_first_room()
		GameManager.player_coord = Vector2(-1, 0)
	else:
		GameManager.player_coord = Vector2.ZERO
	
	GameManager.exit_coord = grid_size - Vector2(1, 1)
	global_position -= grid_size * cell_distance / 2

func _create_first_room():
	first_room = _create_cell(Vector2(-1, 0))
	var door = _add_door_to_cell(first_room, Vector2.RIGHT)
	door.close()
	move_child(door, 0)
	add_child(first_room)
	move_child(first_room, 0)

func get_first_room():
	return first_room if first_room != null else grid_data[0][0]

func get_room(coord: Vector2):
	if coord.y >= 0 and coord.y < grid_data.size():
		if coord.x == -1:
			return first_room
		
		if coord.x >= 0 and coord.y < grid_data[coord.y].size():
			return grid_data[coord.y][coord.x]

	return null

func update_entity_states():
	for c in get_children():
		if c.has_method("update_entities"):
			c.update_entities()

func _create_cell(coord: Vector2):
	var cell = cell_scene.instantiate() as Cell
	cell.position = cell_distance * coord
	cell.coord = coord
	cell.cell_clicked.connect(func(): GameManager.clicked_cell(cell))
	return cell

func _create_missing_doors(cell: Cell, coord: Vector2):
	var dirs =  []

	if coord.y > 0:
		dirs.append(Vector2.UP)
	if coord.x > 0:
		dirs.append(Vector2.LEFT)
	if coord.y < grid_size.y - 1:
		dirs.append(Vector2.DOWN)
	if coord.x < grid_size.x - 1:
		dirs.append(Vector2.RIGHT)
	
	for dir in dirs:
		_add_door_to_cell(cell, dir)

func _add_door_to_cell(cell: Cell, dir: Vector2):
	if cell.get_door(dir): return
	var door = door_scene.instantiate()
	cell.add_door(dir, door)
	add_child(door)
	return door
