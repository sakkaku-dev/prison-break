extends Node

signal cell_clicked(cell)
signal cell_view_ready()
signal played_turn()
signal reached_exit()
signal player_moved()

signal ammo_changed()
signal health_changed()

var exit_coord := Vector2.ZERO

var player_coord := Vector2.ZERO
var player_health := 3

var enemies := {}
var enemy_alert_state = false

var ammo := 0

var level := 0

func move_player(dir: Vector2):
	player_coord += dir
	player_moved.emit()
	
	if player_coord == exit_coord:
		reached_exit.emit()
		level += 1

func clicked_cell(cell: Cell):
	cell_clicked.emit(cell)

func move_enemy(id: int, dir: Vector2):
	enemies[id] = enemies[id] + dir

func add_enemy(id: int, coord: Vector2):
	enemies[id] = coord

func get_enemy_count_at(coord: Vector2):
	return enemies.values().filter(func(x): return x == coord).size()

func is_in_alert():
	return enemy_alert_state
