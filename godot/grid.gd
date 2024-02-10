extends Node2D

@export var cell_scene: PackedScene
@export var door_scene: PackedScene
@export var cell_distance := Vector2(160, 120)
@export var grid_size := Vector2(5, 5)

var grid_data: Array[Array] = []

func _ready():
	grid_data = []
	
	for y in grid_size.y:
		grid_data.append([])
		for x in grid_size.x:
			var cell = cell_scene.instantiate() as Cell
			var coord = Vector2(x, y)
			cell.position = cell_distance * coord
			cell.coord = coord
			cell.cell_clicked.connect(func(): GameManager.cell_clicked.emit(cell))
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

	global_position -= grid_size * cell_distance / 2
	
	GameManager.cell_view_ready.connect(func():
		GameManager.cell_clicked.emit(grid_data[0][0])
	)

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
		if cell.get_door(dir): continue
		var door = door_scene.instantiate()
		cell.add_door(dir, door)
		add_child(door)
