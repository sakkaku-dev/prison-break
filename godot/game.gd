extends Node2D

@onready var turn_timer = $TurnTimer
@onready var grid = $Grid

var current_cell: Cell
var player_turn = true

func _ready():
	GameManager.cell_clicked.connect(func(cell): current_cell = cell)
	GameManager.cell_view_ready.connect(func():
		GameManager.clicked_cell(grid.get_first_room())
		grid.update_entity_states()
	)

	GameManager.reached_exit.connect(func(): get_tree().reload_current_scene())
	GameManager.player_moved.connect(func(): GameManager.clicked_cell(grid.get_room(GameManager.player_coord)))
	GameManager.played_turn.connect(func(): _do_check())
	turn_timer.timeout.connect(func(): _do_check())
	

func _do_check():
	var changes = [_check_move_player()]
	var has_changed = not changes.filter(func(x): return x).is_empty()
	
	# keep updating until nothing to do anymore
	if has_changed:
		grid.update_entity_states()
		turn_timer.start()
	else:
		player_turn = true

func _check_move_player():
	var cell = grid.get_room(GameManager.player_coord)
	if cell:
		return cell.move_player_if_one_exit()
	else:
		print("Player room not found")

	return false

func _unhandled_input(event: InputEvent):
	if player_turn and current_cell:
		var dir = _get_direction_for_input(event)
		if dir:
			var door = current_cell.get_door(dir)
			if door:
				door.toggle()
				player_turn = false
				GameManager.played_turn.emit()

func _get_direction_for_input(event: InputEvent):
	if event.is_action_pressed("move_down"):
		return Vector2.DOWN
	if event.is_action_pressed("move_up"):
		return Vector2.UP
	if event.is_action_pressed("move_left"):
		return Vector2.LEFT
	if event.is_action_pressed("move_right"):
		return Vector2.RIGHT
	
	return Vector2.ZERO
