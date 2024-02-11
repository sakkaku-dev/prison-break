extends Node

signal cell_clicked(cell)
signal cell_view_ready()
signal played_turn()

var player_coord: Vector2

func move_player(dir: Vector2):
	player_coord += dir
