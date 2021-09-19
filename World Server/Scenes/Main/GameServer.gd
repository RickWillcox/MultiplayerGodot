###############################################
#        World Server Start 
#		 Connections: Client    
#        port 1909                        
###############################################


extends Node

onready var player_verification_process = get_node("PlayerVerification")
onready var combat_functions = get_node("Combat")

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

var expected_tokens = []
var player_state_collection = {}

func _ready():
	StartServer()
		
func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	#print("World Server Started")

	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")	
	
func _Peer_Connected(player_id):
	#print("User: " + str(player_id) + " connected")
	player_verification_process.start(player_id)
	
func _Peer_Disconnected(player_id):
	#print("User: " + str(player_id) + " disconnected")
	if has_node(str(player_id)):
		get_node(str(player_id)).queue_free()
		player_state_collection.erase(player_id)
		rpc_id(0, "DespawnPlayer", player_id)
		
remote func FetchServerTime(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnServerTime", OS.get_system_time_msecs(), client_time)	
	
remote func DetermineLatency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnLatency", client_time)
	
func Fetch_Token(player_id):
	rpc_id(player_id, "FetchToken")
	
remote func ReturnToken(token):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.Verify(player_id, token)

func ReturnTokenVerificationResults(player_id, result):
	rpc_id(player_id, "ReturnTokenVerificationResults", result)
	if result == true:
		rpc_id(0, "SpawnNewPlayer", player_id, Vector2(450, 220))

remote func FetchSkillDamage(skill_name, requester):
	var player_id = get_tree().get_rpc_sender_id()
	var damage = get_node("Combat").FetchSkillDamage(skill_name)
	rpc_id(player_id, "ReturnSkillDamage", damage, requester)
	

remote func FetchPlayerStats():
	var player_id = get_tree().get_rpc_sender_id()
	var player_stats = get_node(str(player_id)).player_stats
	rpc_id(player_id, "ReturnPlayerStats", player_stats)

func _on_TokenExpiration_timeout():
	var current_time = OS.get_unix_time()
	var token_time
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1, -1, -1):
			token_time = int(expected_tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_tokens.remove(i)

remote func ReceivePlayerState(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_state_collection.has(player_id): #check if player is in current collection
		if player_state_collection[player_id]["T"] < player_state["T"]: #check if player state is the latest one
			player_state_collection[player_id] = player_state #replace the player state in collection
	else:
		player_state_collection[player_id] = player_state #add player state to the collection
	
func SendWorldState(world_state): #in case of maps or chunks you will want to track player collection and send accordingly
	rpc_unreliable_id(0, "ReceiveWorldState", world_state)

remote func SendNPCHit(enemy_id, damage):
	get_node("Map").NPCHit(enemy_id, damage)

remote func Attack(position, animation_vector, spawn_time, a_rotation, a_position, a_direction):
	var player_id = get_tree().get_rpc_sender_id()
	get_node("ServerMap").SpawnAttack(spawn_time, a_rotation, a_position, a_direction, player_id)
	rpc_id(0, "ReceiveAttack", position, animation_vector, spawn_time, player_id)
