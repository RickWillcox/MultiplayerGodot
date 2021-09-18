extends Node

var network = NetworkedMultiplayerENet.new()
var max_servers = 5
var port = 1911
var hashed_password
var salt

func _ready():
	StartServer()
	#var salt = "398726498276527402347njh234234234234kbkhjvasdasdasdasdasdcso67893n3242342"
	#var hashed_password = GenerateHashedPassword("This@23ismypasswasdasdasdord", salt)
		
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
	else:
		var retreived_salt = PlayerData.PlayerIDs[username].Salt
		hashed_password = GenerateHashedPassword(password, retreived_salt)
		if not PlayerData.PlayerIDs[username].Password == hashed_password:
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

remote func CreateAccount(username, password, player_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var message
	if PlayerData.PlayerIDs.has(username):
		result = false
		message = 2
	else:
		result = true
		message = 3
		var salt = GenerateSalt()
		var hashed_password = GenerateHashedPassword(password, salt)
		PlayerData.PlayerIDs[username] = {"Password": hashed_password, "Salt" : salt}
		PlayerData.SavePlayerIDs()
	
	rpc_id(gateway_id, "CreateAccountResults", result, player_id, message)

func GenerateSalt():
	randomize()
	var salt = str(randi()).sha256_text()
	print("Salt: " + salt)
	return salt

func GenerateHashedPassword(password, salt):
	var start_time = OS.get_system_time_msecs()
	var hashed_password = password
	var rounds = pow(2,18) #262,144 times
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	print("Hashing took: " + str((OS.get_system_time_msecs() - start_time)) + "ms")
	return hashed_password
