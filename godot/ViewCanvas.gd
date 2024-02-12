extends CanvasLayer

@onready var black_screen = $BlackScreen

func _ready():
	black_screen.hide()
	GameManager.player_died.connect(func(): black_screen.show())
