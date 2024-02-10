extends Sprite2D

@export var frames := 6
@export var hurtbox: Hurtbox

@onready var start_frame := frame

func _ready():
	hurtbox.hit.connect(func():
		var p = 1 - (float(hurtbox.health) / float(hurtbox.max_health))
		var add_frames = ceil(frames * p)
		
		frame = start_frame + add_frames
	)
