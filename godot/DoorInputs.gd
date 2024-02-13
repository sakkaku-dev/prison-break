class_name DoorInputs
extends Control

@export var opened_color := Color.GREEN
@export var closed_color := Color.RED

@onready var top = $DoorInputs/Top
@onready var bot = $DoorInputs/Bot
@onready var left = $DoorInputs/Left
@onready var right = $DoorInputs/Right

@onready var hide_pos = Vector2.DOWN * 10

var tw: Tween
var _doors := {}

func _ready():
	modulate = Color.TRANSPARENT

func setup_for_doors(doors: Dictionary):
	top.visible = Vector2.UP in doors
	bot.visible = Vector2.DOWN in doors
	left.visible = Vector2.LEFT in doors
	right.visible = Vector2.RIGHT in doors
	_doors = doors

func open():
	if tw and tw.is_running():
		tw.kill()
		
	position = hide_pos
	_update_doors()
	
	tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	tw.tween_property(self, "modulate", Color.WHITE, 1.0)
	tw.tween_property(self, "position", Vector2.ZERO, 0.5)

func close():
	if tw and tw.is_running():
		tw.kill()
	
	tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	tw.tween_property(self, "modulate", Color.TRANSPARENT, 1.0)
	tw.tween_property(self, "position", hide_pos, 0.5)

func _update_doors():
	if top.visible:
		top.modulate = opened_color if _doors[Vector2.UP].is_open else closed_color
	if bot.visible:
		bot.modulate = opened_color if _doors[Vector2.DOWN].is_open else closed_color
	if right.visible:
		right.modulate = opened_color if _doors[Vector2.RIGHT].is_open else closed_color
	if left.visible:
		left.modulate = opened_color if _doors[Vector2.LEFT].is_open else closed_color
