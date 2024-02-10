class_name Hurtbox
extends Area2D

signal died()
signal hit()

@export var max_health := 4
@onready var health := max_health

func deal_damage(dmg):
	health = max(health - dmg, 0)
	hit.emit()
	
	if health <= 0:
		died.emit()
