extends Node2D

var icespear = preload("res://Scenes/Player/ServerIceSpear.tscn")
var enemy_spawn = preload("res://Scenes/ServerEnemy.tscn")

func SpawnAttack(spawn_time, a_rotation, a_position, a_direction, player_id):
	var icespear_instance = icespear.instance()
	icespear_instance.player_id = player_id
	icespear_instance.impulse_rotation = a_rotation
	icespear_instance.position = a_position
	icespear_instance.direction = a_direction
	add_child(icespear_instance)
	
func SpawnEnemy(enemy_id, location):
	var enemy_spawn_instance = enemy_spawn.instance()
	enemy_spawn_instance.name = str(enemy_id)
	enemy_spawn_instance.position = location
	get_node("YSort/Enemies/").add_child(enemy_spawn_instance, true)
