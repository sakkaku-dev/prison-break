extends CharacterBody2D

@onready var animation_player = $AnimationPlayer

func _on_hurt_box_died():
	animation_player.play("death")
	await animation_player.animation_finished
	queue_free()
