###############################################
#        Client connect to World Server    
#        port 1909                        
###############################################

extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "192.99.247.42"
var port = 1909

var token

func _ready():
	pass

func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
		
func _OnConnectionFailed():
	print("Failed to connected to server")

func _OnConnectionSucceeded():
	print("Successfully connected to server")

remote func FetchToken():
	rpc_id(1, "ReturnToken", token)
	
func FetchSkillDamage(skill_name, requester):
	rpc_id(1, "FetchSkillDamage", skill_name, requester)
	
remote func ReturnTokenVerificationResults(result):
	if result == true:
		get_node("../SceneHandler/Map/GUI/LoginScreen").queue_free()
		print("Successful Token Verification")
	else:
		print("Login Failed please try again")
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_button.disabled = false

remote func ReturnSkillDamage(s_damage, requester):
	instance_from_id(requester).SetDamage(s_damage)

func FetchPlayerStats():
	rpc_id(1, "FetchPlayerStats")

remote func ReturnPlayerStats(stats):
	get_node("../SceneHandler/Map/GUI/PlayerStats").LoadPlayerStats(stats)
	
