class_name DoorInputs
extends Control

@onready var top = $DoorInputs/Top
@onready var bot = $DoorInputs/Bot
@onready var left = $DoorInputs/Left
@onready var right = $DoorInputs/Right

@onready var hide_pos = Vector2.DOWN * 10

var tw: Tween

func _ready():
	modulate = Color.TRANSPARENT

func setup_for_doors(doors: Dictionary):
	top.visible = Vector2.UP in doors
	bot.visible = Vector2.DOWN in doors
	left.visible = Vector2.LEFT in doors
	right.visible = Vector2.RIGHT in doors

func open():
	if tw and tw.is_running():
		tw.kill()
		
	position = hide_pos
	
	tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	tw.tween_property(self, "modulate", Color.WHITE, 1.0)
	tw.tween_property(self, "position", Vector2.ZERO, 0.5)

func close():
	if tw and tw.is_running():
		tw.kill()
	
	tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	tw.tween_property(self, "modulate", Color.TRANSPARENT, 1.0)
	tw.tween_property(self, "position", hide_pos, 0.5)
