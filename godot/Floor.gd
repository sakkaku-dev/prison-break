extends Label

func _ready():
	_update()
	GameManager.level_changed.connect(_update)
	
func _update():
	text = "Basement Level %s" % GameManager.get_current_floor()
