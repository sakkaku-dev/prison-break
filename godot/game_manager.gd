extends Node

signal cell_clicked(cell)
signal cell_view_ready()

signal played_turn()
signal player_moved()
signal reached_exit()
signal player_died()

signal ammo_changed()
signal health_changed()

var exit_coord := Vector2.ZERO
var player_coord := Vector2.ZERO
var loot_coords := []
var enemies := {}
var enemy_alert_state = false

var player_health := 3
var ammo := 0
var level := 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func is_first_level():
	return GameManager.level == 0

func restart_game():
	player_health = 3
	ammo = 0
	level = 0
	reached_exit.emit()

func move_player(dir: Vector2):
	player_coord += dir
	player_moved.emit()

func exit_level():
	if is_player_at_exit():
		reached_exit.emit()
		level += 1

func is_player_at_exit():
	return player_coord == exit_coord

func clicked_cell(cell: Cell):
	cell_clicked.emit(cell)

func add_loot(coord: Vector2):
	loot_coords.append(coord)

func move_enemy(id: int, dir: Vector2):
	enemies[id] = enemies[id] + dir

func add_enemy(id: int, coord: Vector2):
	enemies[id] = coord

func get_enemy_count_at(coord: Vector2):
	return enemies.values().filter(func(x): return x == coord).size()

func is_in_alert():
	return enemy_alert_state

func is_player_at_loot():
	return player_coord in loot_coords
	
func consume_loot():
	loot_coords.erase(player_coord)

func add_ammo(amount: int):
	ammo += amount
	ammo_changed.emit()

func is_player_fighting():
	return get_enemy_count_at(player_coord) > 0

func is_enemy_fighting(enemy_id: int):
	return enemies[enemy_id] == player_coord

func hurt_player(damage: int):
	player_health -= damage
	health_changed.emit()
	if player_health <= 0:
		player_died.emit()

func is_player_dead():
	return player_health <= 0
