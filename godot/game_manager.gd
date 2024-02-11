extends Node

signal cell_clicked(cell)
signal cell_view_ready()
signal played_turn()
signal reached_exit()
signal player_moved()

var player_coord := Vector2.ZERO
var exit_coord := Vector2.ZERO
var enemies := {}
var level := 0

func move_player(dir: Vector2):
	player_coord += dir
	player_moved.emit()
	
	if player_coord == exit_coord:
		reached_exit.emit()
		level += 1

func clicked_cell(cell: Cell):
	cell_clicked.emit(cell)

func add_enemy(id: int, coord: Vector2):
	enemies[id] = coord

func get_enemy_count_at(coord: Vector2):
	return enemies.values().filter(func(x): return x == coord).size()
