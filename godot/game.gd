extends Node2D

@onready var turn_timer = $TurnTimer
@onready var grid = $Grid

var last_door := Vector2.ZERO

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
		last_door = Vector2.ZERO
	)
	turn_timer.timeout.connect(func(): _process_turn())

func _process_turn():
	if GameManager.is_player_at_loot():
		_get_player_room().picked_up_loot()
		GameManager.ammo += 10
		
	elif GameManager.is_player_fighting():
		_get_player_room().fight()
		
		if GameManager.ammo <= 0:
			GameManager.player_health -= 1000 # game over
		else:
			GameManager.player_fight()
		
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

func _get_player_room():
	return grid.get_room(GameManager.player_coord) as Cell

func _needs_processing():
	var new_cell = grid.get_room(GameManager.player_coord) as Cell
	return GameManager.is_player_at_loot() or GameManager.is_player_fighting() or GameManager.is_player_at_exit() or new_cell.get_player_move_dir()

func _check_move_player():
	var cell = grid.get_room(GameManager.player_coord) as Cell
	
	var move_dir = cell.get_player_move_dir()
	if move_dir:
		_remove_moved_door_mark()
		cell.move_player(move_dir)
		return true
	
	if last_door:
		var changed_door = cell.get_door(last_door)
		if changed_door and changed_door.is_open:
			_remove_moved_door_mark()
			cell.move_player(last_door)
			return true

	return false

func _remove_moved_door_mark():
	for c in grid.get_children():
		if c.has_method("remove_move_mark"):
			c.remove_move_mark()

func _move_enemies():
	for enemy in GameManager.enemies:
		var coord = GameManager.enemies[enemy].coord
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
				
				if current_cell.coord == GameManager.player_coord:
					last_door = dir
				elif current_cell.coord + dir == GameManager.player_coord:
					last_door = -dir
				else:
					last_door = Vector2.ZERO
					
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
