extends Area2D

@export var damage := 1
@export var speed := 300
@export var dir := Vector2.RIGHT

func _ready():
	area_entered.connect(func(x):
		if x is Hurtbox:
			x.deal_damage(damage)
		queue_free()
	)
	body_entered.connect(func(x: Node2D): queue_free())

func _physics_process(delta):
	translate(dir.rotated(global_rotation) * speed * delta)
