extends HBoxContainer

@export var empty_icon: Texture2D
@export var fill_icon: Texture2D

@export var texture_rect: TextureRect
@export var progress_bar: ProgressBar

func _ready():
	_update()
	GameManager.ammo_changed.connect(_update)

func _update():
	progress_bar.value = GameManager.ammo
	texture_rect.texture = empty_icon if progress_bar.value == progress_bar.min_value else fill_icon
