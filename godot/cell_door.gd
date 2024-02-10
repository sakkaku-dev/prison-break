class_name CellDoor
extends Node2D

signal opened()
signal closed()

@export var open_color := Color.WHITE
@export var close_color := Color.RED

var is_open = true

func toggle():
	if is_open:
		close()
	else:
		open()

func open():
	if is_open: return
	
	is_open = true
	modulate = open_color
	opened.emit()

func close():
	if not is_open: return
	
	is_open = false
	modulate = close_color
	closed.emit()
