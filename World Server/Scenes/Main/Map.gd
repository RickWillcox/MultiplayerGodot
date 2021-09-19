extends Node

var enemy_id_counter = 1 
var enemy_maximum = 2
var enemy_types = ["Spooky Man"] #list of enemies that spawn
var enemy_spawn_points = [Vector2 (900, 470), Vector2 (300, 600), Vector2 (150, 90)]
var open_locations = [0,1,2]
var occupied_locations = {}
var enemy_list = {}

func _ready(): 
	var timer = Timer.new()
	timer.wait_time = 3
	timer.autostart = true
	timer.connect("timeout", self, "SpawnEnemy")
	self.add_child(timer)
	
func SpawnEnemy():
	if enemy_list.size() >= enemy_maximum:
		pass #maximum enemies already on the map
	else:
		randomize()
		var type = enemy_types[randi() % enemy_types.size()] #select random enemy
		var rng_location_index = randi() % open_locations.size()
		var location = enemy_spawn_points[open_locations[rng_location_index]]  #select random location to spawn at
		occupied_locations[enemy_id_counter] = open_locations[rng_location_index]
		open_locations.remove(rng_location_index)
		enemy_list[enemy_id_counter] = {"EnemyType": type, "EnemyLocation": location, "EnemyCurrentHealth": 500, "EnemyMaxHealth": 500, "EnemyState": "Idle", "time_out": 1}
		enemy_id_counter += 1
	for enemy in enemy_list.keys():
		if enemy_list[enemy]["EnemyState"] == "Dead":
			if enemy_list[enemy]["time_out"] == 0:
				enemy_list.erase(enemy)
			else:
				enemy_list[enemy]["time_out"] = enemy_list[enemy]["time_out"] -1
				
func NPCHit(enemy_id, damage):
	if enemy_list[enemy_id]["EnemyCurrentHealth"] <= 0:
		pass
	else:
		enemy_list[enemy_id]["EnemyCurrentHealth"] = enemy_list[enemy_id]["EnemyCurrentHealth"] - damage
		if enemy_list[enemy_id]["EnemyCurrentHealth"] <= 0:
			enemy_list[enemy_id]["EnemyState"] = "Dead"
			open_locations.append(occupied_locations[enemy_id])
			occupied_locations.erase(enemy_id)
