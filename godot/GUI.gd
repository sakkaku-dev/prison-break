extends CanvasLayer

@export var gameover: Control
@export var escaped: Control

func _ready():
	gameover.hide()
	escaped.hide()
	
	GameManager.player_died.connect(func():
		get_tree().paused = true
		gameover.show()
	)
	
	GameManager.player_escaped.connect(func():
		get_tree().paused = true
		escaped.show()
	)


func _on_button_pressed():
	get_tree().paused = false
	GameManager.restart_game()
