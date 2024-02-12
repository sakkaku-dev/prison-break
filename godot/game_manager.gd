extends Node

signal cell_clicked(cell)
signal cell_view_ready()

signal played_turn()
signal player_moved()
signal reached_exit()
signal player_died()

signal looted_chest(coord)
signal killed_enemy(coord)

signal ammo_changed()
signal health_changed()

const MAX_HEALTH = 3
const MAX_AMMO = 10
const GUN_DAMAGE = 2

const ENEMY_HEALTH = 4
const ENEMY_DAMAGE = 1

var exit_coord := Vector2.ZERO
var player_coord := Vector2.ZERO
var loot_coords := []
var enemies := {}
var enemy_alert_state = false

var looted_coords := []

var player_health := MAX_HEALTH:
	set(v):
		player_health = clamp(v, 0, MAX_HEALTH)
		health_changed.emit()
		if player_health <= 0:
			player_died.emit()
		print("Health %s" % v)
var ammo := 0:
	set(v):
		ammo = clamp(v, 0, MAX_AMMO)
		ammo_changed.emit()
		print("Ammo %s" % v)
	
var level := 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func is_first_level():
	return GameManager.level == 0

func restart_game():
	player_health = MAX_HEALTH
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
	enemies[id].coord = enemies[id].coord + dir

func add_enemy(id: int, coord: Vector2):
	enemies[id] = { "coord": coord, "health": ENEMY_HEALTH }

func get_enemy_count_at(coord: Vector2):
	return enemies.values().filter(func(x): return x.coord == coord).size()

func is_in_alert(): # TODO: change enemy state
	return enemy_alert_state

func is_player_at_loot():
	return player_coord in loot_coords
	
func consume_loot(coord):
	loot_coords.erase(coord)
	looted_coords.append(coord)
	looted_chest.emit(coord)

func player_fight():
	var enemies_by_player = _enemies_at(player_coord)
	if enemies_by_player.is_empty(): return
	
	var enemy_id = enemies_by_player[0]
	var first_enemy = enemies[enemy_id]
	self.ammo -= 1
	first_enemy.health -= GUN_DAMAGE
	
	if first_enemy.health <= 0:
		enemies.erase(enemy_id)
		killed_enemy.emit(player_coord)
	else:
		self.player_health -= ENEMY_DAMAGE
	
func _enemies_at(coord):
	var result = []
	for enemy in enemies:
		var pos = enemies[enemy].coord
		if pos != player_coord: continue
		
		result.append(enemy)
	return result

func is_player_fighting():
	return get_enemy_count_at(player_coord) > 0

func is_enemy_fighting(enemy_id: int):
	return enemies[enemy_id].coord == player_coord

func hurt_player(damage: int):
	player_health -= damage

func is_player_dead():
	return player_health <= 0
