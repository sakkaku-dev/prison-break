class_name Cell
extends Node2D

signal cell_clicked()

@onready var door_positions = {
	Vector2.DOWN: $BotDoor,
	Vector2.RIGHT: $RightDoor,
}

var doors = {}
var coord: Vector2

func _ready():
	
	for dir in door_positions.keys():
		_position_door(dir)

func _position_door(dir: Vector2):
	if not dir in doors: return
	
	var door = doors[dir]
	door.global_position = door_positions[dir].global_position
	door.global_rotation = Vector2.RIGHT.angle_to(dir)

func add_door(dir: Vector2, door: CellDoor):
	doors[dir] = door

func get_door(dir: Vector2):
	if dir in doors:
		return doors[dir]
	return null


func _on_control_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		cell_clicked.emit()
