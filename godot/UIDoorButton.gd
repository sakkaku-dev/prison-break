extends TextureButton

@export var door_direction := Vector2.RIGHT

func _ready():
	toggle_mode = true
	GameManager.cell_clicked.connect(func(cell: Cell):
		var door = cell.get_door(door_direction) as CellDoor
		if door == null:
			disabled = true
			return
		
		disabled = false
		button_pressed = door.is_open
	)
