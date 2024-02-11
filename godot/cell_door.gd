class_name CellDoor
extends Node2D

signal opened()
signal closed()

@export var open_color := Color.WHITE
@export var close_color := Color.RED
@export var moved_color := Color.GREEN

var is_open = true
var has_moved = false

func toggle():
	if is_open:
		close()
	else:
		open()

func open():
	if is_open: return
	
	is_open = true
	opened.emit()
	_update_color()

func close():
	if not is_open: return
	
	is_open = false
	has_moved = false
	closed.emit()
	
	_update_color()

func move():
	has_moved = true
	_update_color()

func remove_move_mark():
	has_moved = false
	_update_color()

func _update_color():
	if has_moved:
		modulate = moved_color
	elif is_open:
		modulate = open_color
	else:
		modulate = close_color
