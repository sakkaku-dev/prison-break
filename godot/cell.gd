class_name Cell
extends Node2D

signal cell_clicked()

@export var normal_color := Color.DARK_GRAY
@export var selected_color := Color.WHITE

@export var player_icon: Control
@export var enemy_icon: Control
@export var enemy_icon_count: Label
@export var chest_icon: Control
@export var open_chest_icon: Control
@export var medkit_icon: Control
@export var open_medkit_icon: Control
@export var exit_icon: Control

@export var health_icon: Control
@export var fight_icon: Control
@export var looted_icon: Control
@export var looted_text: Label

@onready var door_positions = {
	Vector2.DOWN: $BotDoor,
	Vector2.RIGHT: $RightDoor,
}

var doors = {}
var coord: Vector2

func _ready():
	fight_icon.modulate = Color.TRANSPARENT
	looted_icon.modulate = Color.TRANSPARENT
	health_icon.modulate = Color.TRANSPARENT
	
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
	player_icon.visible = has_player()
	exit_icon.visible = has_exit()
	medkit_icon.visible = has_medkit()
	open_medkit_icon.visible = has_open_medkit()
	
	chest_icon.visible = has_chest()
	open_chest_icon.visible = has_open_chest()
	
	var enemies = get_enemy_count()
	enemy_icon.visible = enemies > 0
	enemy_icon_count.visible = enemies > 1
	enemy_icon_count.text = "%sx" % enemies

func has_chest():
	return coord in GameManager.loot_coords

func has_open_chest():
	return coord in GameManager.looted_coords

func has_medkit():
	return coord in GameManager.medkit_coords
	
func has_open_medkit():
	return coord in GameManager.opened_medkits

func get_enemy_count():
	return GameManager.get_enemy_count_at(coord)

func has_player():
	return GameManager.player_coord == coord

func has_exit():
	return GameManager.exit_coord == coord

func fight():
	await _tween_show_icon(fight_icon)
	
func _tween_show_icon(icon: Control):
	icon.global_position = global_position - icon.size / 2 + Vector2.UP * 10
	var tw = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(icon, "modulate", Color.WHITE, 0.5)
	tw.tween_property(icon, "modulate", Color.TRANSPARENT, 0.5).set_delay(0.5)
	tw.tween_property(icon, "global_position", icon.global_position + Vector2.UP * 20, 1.0)
	await tw.finished

func picked_up_loot(amount: int):
	GameManager.consume_loot(coord)
	update_entities()
	await _tween_show_icon(looted_icon)
	looted_text.text = str(amount)

func pickup_medkit():
	GameManager.pickup_medkit(coord)
	update_entities()
	await _tween_show_icon(health_icon)

func get_player_move_dir():
	var open_dir = []
	var only_opened = []
	for dir in doors:
		var door = doors[dir]
		if door.is_open:
			only_opened.append(dir)
			if not door.has_moved:
				open_dir.append(dir)
	
	if open_dir.size() == 1:
		return open_dir[0]
	
	return Vector2.ZERO

func move_player(move_dir: Vector2):
	#doors[move_dir].move()
	GameManager.move_player(move_dir)

func get_available_directions():
	var result = []
	for k in doors.keys():
		var door = doors[k]
		if door.is_open:
			result.append(k)
	return result
