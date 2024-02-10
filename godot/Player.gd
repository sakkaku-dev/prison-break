extends CharacterBody2D

@export var accel := 800
@export var speed := 150
@export var bullet: PackedScene
@export var bullet_spawn: Node2D

@onready var animation_player = $AnimationPlayer
@onready var body = $Body
@onready var hand = $Hand
@onready var interact = $Interact

func _get_aim():
	return global_position.direction_to(get_global_mouse_position())

func _physics_process(delta):
	var motion = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"),
	)
	motion = motion.normalized()
	
	animation_player.play("idle" if motion.length() == 0 else "move")
	
	var aim = _get_aim()
	body.scale.x = -1 if aim.x < 0 else 1
	hand.global_rotation = Vector2.RIGHT.angle_to(aim)
	
	velocity = velocity.move_toward(motion * speed, accel * delta)
	move_and_slide()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("fire"):
		var b = bullet.instantiate()
		get_tree().current_scene.add_child(b)
		b.global_position = bullet_spawn.global_position
		b.global_rotation = bullet_spawn.global_rotation
	elif event.is_action_pressed("interact"):
		interact.interact()
