extends StaticBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var highlight = $Highlight
@onready var point_light_2d = $LightRoot/PointLight2D

var is_opened = false
var last_frame = 11

func _ready():
	animated_sprite_2d.frame = 0
	animated_sprite_2d.frame_changed.connect(func():
		collision_shape_2d.disabled = animated_sprite_2d.frame >= last_frame
	)

func open(immediate = true):
	if immediate:
		animated_sprite_2d.frame = last_frame
	else:
		animated_sprite_2d.play("open")
	
	is_opened = true
	point_light_2d.enabled = true

func close(immediate = true):
	if immediate:
		animated_sprite_2d.frame = 0
	else:
		animated_sprite_2d.play_backwards("open") # TODO: different animation/pacing
		
	is_opened = false
	point_light_2d.enabled = false
