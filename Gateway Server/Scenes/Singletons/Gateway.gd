extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1910
var max_players = 100
var cert = load("res://Certificate/X509_Certificate.crt")
var key = load("res://Certificate/X509_Key.key")

func _ready():
	StartServer()
	
# warning-ignore:unused_argument
func _process(delta):
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll();
		
func StartServer():
	network.set_dtls_enabled(true)
	network.set_dtls_key(key)
	network.set_dtls_certificate(cert)
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("Gateway Server Started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(gateway_id):
	print("User " + str(gateway_id) + " Connected")
		
func _Peer_Disconnected(gateway_id):
	print("User " + str(gateway_id) + " Disconnected")
	
remote func LoginRequest(username, password):
	print("Login request received")
	var player_id = custom_multiplayer.get_rpc_sender_id()
	Authenticate.AuthenticatePlayer(username, password, player_id)
	
func ReturnLoginRequest(result, player_id, token):
	rpc_id(player_id, "ReturnLoginRequest", result, token)
	network.disconnect_peer(player_id)
	
remote func CreateAccountRequest(username, password):
	print("Account creation request received" + " " + username + " " + password)
	var player_id = custom_multiplayer.get_rpc_sender_id()
	var valid_request = true
	if username == "" or password == "":
		valid_request = false
	if valid_request == true:
		Authenticate.CreateAccount(username.to_lower(), password, player_id)
	else:
		ReturnCreateAccountRequest(valid_request, player_id, 1)
	
func ReturnCreateAccountRequest(valid_request, player_id, message):
	#1 = failed to create, 2 = username already in use, 3 = account created successfully
	rpc_id(player_id, "ReturnCreateAccountRequest", valid_request, message)
		
	
	


