class_name Cell
extends Node2D

signal cell_clicked()

@export var normal_color := Color.DARK_GRAY
@export var selected_color := Color.WHITE

@export var player_icon: Control
@export var enemy_icon: Control
@export var chest_icon: Control

@onready var door_positions = {
	Vector2.DOWN: $BotDoor,
	Vector2.RIGHT: $RightDoor,
}

var doors = {}
var coord: Vector2

func _ready():
	unhighlight()
	update_entities()
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

func unhighlight():
	modulate = normal_color
	
func highlight():
	modulate = selected_color

func update_entities():
	player_icon.visible = GameManager.player_coord == coord
	enemy_icon.visible = false
	chest_icon.visible = false

func move_player_if_one_exit():
	var open_dir = []
	for dir in doors:
		var door = doors[dir]
		if door.is_open and not door.has_moved:
			open_dir.append(dir)
	
	if open_dir.size() == 1:
		var move_dir = open_dir[0]
		doors[move_dir].move()
		GameManager.move_player(move_dir)
