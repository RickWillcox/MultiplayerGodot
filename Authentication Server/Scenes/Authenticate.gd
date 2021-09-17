extends Node

var network = NetworkedMultiplayerENet.new()
var max_servers = 5
var port = 1911


func _ready():
	StartServer()
		
func StartServer():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("Authentication Server Started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(gateway_id):
	print("Gateway " + str(gateway_id) + " Connected")
		
func _Peer_Disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " Disconnected")

remote func AuthenticatePlayer(username, password, player_id):
	var token
	print("Authentication request received")
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	print("Starting Authentication")
	if not PlayerData.PlayerIDs.has(username):
		print("User not found")
		result = false
	elif not PlayerData.PlayerIDs[username].Password == password:
		print("Incorrect password")
		result = false
	else:
		print("Username and Password found in database")
		result = true
		
		randomize()
		####OR token = str(randi()).sha256_text() + str(OS.get_unix_time())
		var random_number = randi()
		var hashed = str(random_number).sha256_text()
		var timestamp = str(OS.get_unix_time())
		token = hashed + timestamp
		var gameserver = "GameServer1"
		print(gameserver)
		GameServers.DistributeLoginToken(token, gameserver)
		
		
		
	print("Authentication result send to gateway")
	rpc_id(gateway_id, "AuthenticationResults", result, player_id, token)

