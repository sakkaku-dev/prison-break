class_name Interactable
extends Area2D

signal interacted
signal highlight(highlight)

@export var sprite: Sprite2D

func do_highlight():
	highlight.emit(true)


func do_unhighlight():
	highlight.emit(false)

func interact():
	interacted.emit()
