extends HBoxContainer

@export var progress_bar: ProgressBar

func _ready():
	progress_bar.max_value = GameManager.MAX_HEALTH
	progress_bar.value = GameManager.player_health
	
	_update()
	GameManager.health_changed.connect(_update)

func _update():
	progress_bar.value = GameManager.player_health
