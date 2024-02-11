extends Node

signal cell_clicked(cell)
signal cell_view_ready()
signal played_turn()
signal reached_exit()
signal player_moved()

var player_coord := Vector2.ZERO
var exit_coord := Vector2.ZERO
var level := 0

#var current_cell: Cell

func move_player(dir: Vector2):
	player_coord += dir
	player_moved.emit()
	
	if player_coord == exit_coord:
		reached_exit.emit()
		level += 1

func clicked_cell(cell: Cell):
	#current_cell = cell
	cell_clicked.emit(cell)
