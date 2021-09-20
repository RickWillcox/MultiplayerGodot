###############################################
#        Client connect to World Server    
#        port 1909                        
###############################################

extends Node

var network = NetworkedMultiplayerENet.new()
#var ip = "192.99.247.42"
var ip = "127.0.0.1"
var port = 1909

var client_clock = 0
var decimal_collector : float = 0
var latency_array = []
var latency = 0
var delta_latency = 0

var token

func _ready():
	pass

func _physics_process(delta):
	client_clock += int(delta*1000) + delta_latency
	delta_latency -= delta_latency
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.0

func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
		
func _OnConnectionFailed():
	print("Failed to connected to server")

func _OnConnectionSucceeded():
	print("Successfully connected to server")
	rpc_id(1, "FetchServerTime", OS.get_system_time_msecs()) #current client time
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "DetermineLatency")
	self.add_child(timer)
	
remote func ReturnServerTime(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency
	
func DetermineLatency():
	rpc_id(1, "DetermineLatency", OS.get_system_time_msecs())
	
remote func ReturnLatency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size()-1,-1,-1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		#print("New Latency: ", latency)
		#print("Delta Latency: ", delta_latency)
		latency_array.clear()
	pass
	

remote func FetchToken():
	rpc_id(1, "ReturnToken", token)
	
#func FetchSkillDamage(skill_name, requester):
#	rpc_id(1, "FetchSkillDamage", skill_name, requester)
	
remote func ReturnTokenVerificationResults(result):
	if result == true:
		get_node("../SceneHandler/Map/GUI/LoginScreen").queue_free()
		get_node("../SceneHandler/Map/YSort/Player").set_physics_process(true)
		#print("Successful Token Verification")
	else:
		#print("Login Failed please try again")
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_button.disabled = false
		
func SendPlayerState(player_state):
	rpc_unreliable_id(1, "ReceivePlayerState", player_state)
	
remote func ReceiveWorldState(world_state):
	get_node("../SceneHandler/Map").UpdateWorldState(world_state)

#remote func ReturnSkillDamage(s_damage, requester):
#	instance_from_id(requester).SetDamage(s_damage)

func FetchPlayerStats():
	rpc_id(1, "FetchPlayerStats")

remote func ReturnPlayerStats(stats):
	get_node("../SceneHandler/Map/GUI/PlayerStats").LoadPlayerStats(stats)
	
remote func SpawnNewPlayer(player_id, spawn_position):
	get_node("../SceneHandler/Map").SpawnNewPlayer(player_id, spawn_position)

remote func DespawnPlayer(player_id):
	get_node("../SceneHandler/Map").DespawnPlayer(player_id)

#func NPCHit(enemy_id, damage):
#	rpc_id(1, "SendNPCHit", enemy_id, damage)

func SendAttack(position, animation_vector, a_rotation, a_position, a_direction):
	rpc_id(1, "Attack", position, animation_vector, client_clock, a_rotation, a_position, a_direction)
	
remote func ReceiveAttack(position, animation_vector, spawn_time, player_id):
	if player_id == get_tree().get_network_unique_id():
		pass #make client side predictions here
	else: get_node("/root/SceneHandler/Map/YSort/OtherPlayers/" + str(player_id)).attack_dict[spawn_time] = {"Position": position, "AnimationVector": animation_vector}
