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

func _ready():
	StartServer()
		
func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("World Server Started")

	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")	
	
func _Peer_Connected(player_id):
	print("User: " + str(player_id) + " connected")
	player_verification_process.start(player_id)
	
func _Peer_Disconnected(player_id):
	print("User: " + str(player_id) + " disconnected")

func Fetch_Token(player_id):
	rpc_id(player_id, "FetchToken")
	
remote func ReturnToken(token):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.Verify(player_id, token)

func ReturnTokenVerificationResults(player_id, result):
	rpc_id(player_id, "ReturnTokenVerificationResults", result)

remote func FetchSkillDamage(skill_name, requester):
	var player_id = get_tree().get_rpc_sender_id()
	var damage = get_node("Combat").FetchSkillDamage(skill_name)
	rpc_id(player_id, "ReturnSkillDamage", damage, requester)
	print("Sending: " + str(damage) + " " + skill_name + " damage to player")

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
	#print("Expected Tokens:")
	#print(expected_tokens)
