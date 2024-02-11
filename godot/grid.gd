extends Node2D

@export var cell_scene: PackedScene
@export var door_scene: PackedScene
@export var cell_distance := Vector2(160, 120)
@export var grid_size := Vector2(5, 5)

var grid_data: Dictionary = {}
var first_room: Cell

func _ready():
	_create_map()

func _create_map():
	for c in get_children():
		remove_child(c)
		
	grid_data = {}
	
	for y in grid_size.y:
		for x in grid_size.x:
			var coord = Vector2(x, y)
			var cell = _create_cell(coord)
			grid_data[coord]= cell
			
			if y > 0:
				var above_cell = grid_data[coord + Vector2.UP]
				var above_door = above_cell.get_door(Vector2.DOWN)
				if above_door:
					cell.add_door(Vector2.UP, above_door)
			
			if x > 0:
				var left_cell = grid_data[coord + Vector2.LEFT]
				var left_door = left_cell.get_door(Vector2.RIGHT)
				if left_door:
					cell.add_door(Vector2.LEFT, left_door)
			
			_create_missing_doors(cell, coord)
			add_child(cell)
	
	if GameManager.is_first_level():
		_create_first_room()
		GameManager.player_coord = Vector2(-1, 0)
	else:
		GameManager.player_coord = Vector2.ZERO
	
	_spawn_enemies()
	_spawn_loot()
	
	GameManager.exit_coord = grid_size - Vector2(1, 1)
	global_position -= grid_size * cell_distance / 2

func _spawn_enemies():
	var enemy_count = ceil(grid_size.x / 2)
	
	# Don't spawn too close to player
	var available_coords = grid_data.keys().filter(func(c): return c.x > 2 and c.y > 2)
	
	for i in range(enemy_count):
		var coord = available_coords.pick_random()
		available_coords.erase(coord)
		GameManager.add_enemy(i, coord)

func _spawn_loot():
	var loot_count = floor(grid_size.x / 2)
	var available_coords = grid_data.keys()
	
	for i in range(loot_count):
		var coord = available_coords.pick_random()
		
		if i == 0 and GameManager.is_first_level():
			var close_coord = available_coords.filter(func(c): return c.x > 0 and c.y > 0 and c.x < 3 and c.y < 3)
			coord = close_coord.pick_random()
		
		available_coords.erase(coord)
		GameManager.add_loot(coord)


func _create_first_room():
	var coord = Vector2(-1, 0)
	first_room = _create_cell(coord)
	grid_data[coord] = first_room
	var door = _add_door_to_cell(first_room, Vector2.RIGHT)
	door.close()
	move_child(door, 0)
	add_child(first_room)
	move_child(first_room, 0)

func get_first_room():
	return first_room if first_room != null else grid_data[Vector2.ZERO]

func get_room(coord: Vector2):
	if coord in grid_data:
		return grid_data[coord]
	
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
