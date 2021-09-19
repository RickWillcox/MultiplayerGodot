extends Node

var network = NetworkedMultiplayerENet.new()
#var ip = "192.99.247.42"
var ip = "127.0.0.1"
var port = 1911


func _ready():
	ConnectToServer()
	
func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)

	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

func _OnConnectionFailed():
	print("Failed to connect to the Authentication Server")
	
func _OnConnectionSucceeded():
	print("Successfully connected to the Authentication Sever")
	
func AuthenticatePlayer(username, password, player_id):
	print("Sending out Authentication Request")
	rpc_id(1, "AuthenticatePlayer", username, password, player_id)
	
remote func AuthenticationResults(result, player_id, token):
	print("Results received and replying to player login request")
	Gateway.ReturnLoginRequest(result, player_id, token)
	
func ReturnLoginRequest(result, player_id):
	rpc_id(player_id, "ReturnLoginRequest", result)
	network.disconnect_peer(player_id)

#my shit
func CreateAccount(username, password, player_id):
	rpc_id(1, "CreateAccount", username, password, player_id)
	print("Sending Create Account Request Gateway > Auth")
	
remote func CreateAccountResults(result, player_id, message):
	print("Results recevied Auth > Gateway and replying to player account request")
	Gateway.ReturnCreateAccountRequest(result, player_id, message)
