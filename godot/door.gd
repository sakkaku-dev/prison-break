extends StaticBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var highlight = $Highlight

var is_opened = false

func _ready():
	animated_sprite_2d.frame = 0
	animated_sprite_2d.frame_changed.connect(func():
		collision_shape_2d.disabled = animated_sprite_2d.frame >= 11
	)

func open():
	if is_opened: return
	animated_sprite_2d.play("default")
	is_opened = true

func _on_area_2d_highlight(hl):
	highlight.visible = hl and not is_opened


func _on_area_2d_interacted():
	open()
