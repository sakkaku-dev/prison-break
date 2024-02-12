extends Node2D

@export var cell_scene: PackedScene
@export var door_scene: PackedScene
@export var cell_distance := Vector2(180, 120)
@export var grid_size := Vector2(5, 5)

var grid_data: Dictionary = {}
var first_room: Cell

const first_level_coord = Vector2(-1, 0)

func _ready():
	var size = min(grid_size.x + GameManager.level, 7)
	grid_size = Vector2(size, size)
	_create_map()

func _create_map():
	for c in get_children():
		remove_child(c)
		
	grid_data = {}
	GameManager.looted_coords = []
	GameManager.opened_medkits = []
	GameManager.medkit_coords = []
	
	if GameManager.is_first_level():
		_create_first_room()
	
	for y in grid_size.y:
		for x in grid_size.x:
			var coord = Vector2(x, y)
			var cell = _create_cell(coord)
			grid_data[coord]= cell
			
			var up_dir = coord + Vector2.UP
			if up_dir in grid_data:
				var above_cell = grid_data[up_dir]
				var above_door = above_cell.get_door(Vector2.DOWN)
				if above_door:
					cell.add_door(Vector2.UP, above_door)
			
			var left_dir = coord + Vector2.LEFT
			if left_dir in grid_data:
				var left_cell = grid_data[left_dir]
				var left_door = left_cell.get_door(Vector2.RIGHT)
				if left_door:
					cell.add_door(Vector2.LEFT, left_door)
			
			_create_missing_doors(cell, coord)
			add_child(cell)
	
	if GameManager.is_first_level():
		GameManager.player_coord = first_level_coord
	else:
		GameManager.player_coord = Vector2.ZERO
	
	_spawn_enemies()
	_spawn_loot()
	_spawn_medkit() # dependent on loot positions
	
	GameManager.exit_coord = grid_size - Vector2(1, 1)
	global_position -= (grid_size-Vector2(1, 1)) * cell_distance / 2

func _create_first_room():
	first_room = _create_cell(first_level_coord)
	grid_data[first_level_coord] = first_room
	var door = _add_door_to_cell(first_room, Vector2.RIGHT)
	door.close()
	add_child(first_room)

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


func _spawn_enemies():
	var enemy_count = ceil(grid_size.x / 2)
	
	# Don't spawn too close to player
	var available_coords = grid_data.keys().filter(func(c): return c.x > 2 or c.y > 2)
	
	for i in range(enemy_count):
		var coord = available_coords.pick_random()
		available_coords.erase(coord)
		GameManager.add_enemy(i, coord)

func _spawn_loot():
	var loot_count = min(floor(grid_size.x / 2), 2)
	
	var close_coords = [Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]
	var available_coords = grid_data.keys().filter(func(c): return c != Vector2.ZERO and c != first_level_coord)
	
	var first = null
	for i in range(loot_count):
		var coord = available_coords.pick_random()
		
		if i == 0 and GameManager.is_first_level():
			coord = close_coords.pick_random()
		else:
			while first != null and first.distance_to(coord) <= 3:
				available_coords.erase(coord)
				coord = available_coords.pick_random()
				#print("%s - %s = %s " % [first, coord, first.distance_to(coord)])
			
		if first == null:
			first = coord
		
		available_coords.erase(coord)
		#print("Picked %s, removing from coords %s" % [coord, available_coords])
		GameManager.add_loot(coord)

func _spawn_medkit():
	if GameManager.is_first_level(): return
	
	var medkit_count = 1
	
	var available_coords = grid_data.keys().filter(func(c): return c != Vector2.ZERO and c != first_level_coord and not c in GameManager.loot_coords)
	for i in range(medkit_count):
		var coord = available_coords.pick_random()
		available_coords.erase(coord)
		GameManager.add_medkit(coord)

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
