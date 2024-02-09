extends CharacterBody2D

@export var accel := 800
@export var speed := 150
@export var jump_force := 300
@export var gravity := 20

@onready var animation_player = $AnimationPlayer
@onready var body = $Body
@onready var hand = $Body/Hand

func _get_aim():
	return global_position.direction_to(get_global_mouse_position())

func _physics_process(delta):
	var motion = Input.get_axis("move_left", "move_right")
	
	if is_on_floor():
		animation_player.play("idle" if abs(motion) == 0 else "move")
	else:
		animation_player.play("jump")
	
	var aim = _get_aim()
	body.scale.x = -1 if aim.x < 0 else 1
	hand.rotation = Vector2.RIGHT.angle_to(Vector2(abs(aim.x), aim.y))
	
	velocity.x = move_toward(velocity.x, motion * speed, accel * delta)
	velocity += Vector2.DOWN * gravity
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force
	
	move_and_slide()
