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
	GameManager.played_turn.connect(func(): _process_turn())
	GameManager.player_moved.connect(func():
		var new_cell = grid.get_room(GameManager.player_coord) as Cell
		GameManager.clicked_cell(new_cell)
	)
	turn_timer.timeout.connect(func(): _process_turn())

func _process_turn():
	if GameManager.is_player_at_loot():
		GameManager.consume_loot()
		GameManager.add_ammo(5)
	elif GameManager.is_player_fighting():
		if GameManager.ammo <= 0:
			GameManager.hurt_player(1000) # game over
		else:
			pass # TODO: simulate fight
		
	elif GameManager.is_player_at_exit():
		GameManager.exit_level()
	else:
		var player_moved = _check_move_player()
		_move_enemies()
	
	grid.update_entity_states()
	
	if _needs_processing():
		turn_timer.start()
	else:
		player_turn = true

func _needs_processing():
	var new_cell = grid.get_room(GameManager.player_coord) as Cell
	return GameManager.is_player_at_loot() or GameManager.is_player_fighting() or GameManager.is_player_at_exit() or new_cell.get_player_move_dir()

func _check_move_player():
	var cell = grid.get_room(GameManager.player_coord)
	if cell:
		return cell.move_player_if_one_exit()
	else:
		print("Player room not found")

	return false

func _move_enemies():
	for enemy in GameManager.enemies:
		var coord = GameManager.enemies[enemy]
		if GameManager.is_in_alert():
			pass
		elif not GameManager.is_enemy_fighting(enemy):
			var room = grid.get_room(coord)
			if room:
				var dirs = room.get_available_directions()
				GameManager.move_enemy(enemy, dirs.pick_random())
			else:
				print("Enemy %s room not found" % enemy)

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
