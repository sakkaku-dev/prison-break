extends TextureButton

@export var door_direction := Vector2.RIGHT

var current_door

func _ready():
	toggle_mode = true
	GameManager.cell_clicked.connect(func(cell: Cell):
		var door = cell.get_door(door_direction) as CellDoor
		current_door = door
		
		if door == null:
			disabled = true
			return
		
		disabled = false
		button_pressed = door.is_open
	)
	
	toggled.connect(func(open):
		if current_door:
			if open:
				current_door.open()
			else:
				current_door.close()
	)
