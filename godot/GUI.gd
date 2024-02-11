extends Control

func _ready():
	hide()
	GameManager.player_died.connect(func():
		get_tree().paused = true
		show()
	)


func _on_button_pressed():
	get_tree().paused = false
	GameManager.restart_game()
