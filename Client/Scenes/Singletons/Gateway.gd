extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1910
var ip = "192.99.247.42"
var cert = load("res://Assets/Certificate/X509_Certificate.crt")

var username
var password
var new_account

signal close_account_screen_signal

func _ready():
	pass
	
# warning-ignore:unused_argument
func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll();
		
func ConnectToServer(_username, _password, _new_account):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false) #set to true when using signed cert (this is for testing only)
	network.set_dtls_certificate(cert)
	username = _username
	password = _password
	new_account = _new_account
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)

	#I think its failing at this point
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")	

func _OnConnectionFailed():	
	print("Failed to connect to the login server")
	print("Pop-up server offline.... or something")
	get_node("../SceneHandler/Map/GUI/LoginScreen").login_button.disabled = false
	
func _OnConnectionSucceeded():
	print("Successfully connected to login server")
	if not new_account:
		RequestLogin()
	else:
		RequestCreateAccount()


func RequestCreateAccount():
	print("Requesting to make new account")
	rpc_id(1, "CreateAccountRequest", username, password)
	username = ""
	password = ""
	
func RequestLogin():
	print("Connecting to gateway to request login")
	rpc_id(1, "LoginRequest", username, password)
	username = ""
	password = ""

remote func ReturnLoginRequest(results, token):
	print("results received: " + str(results))
	if results == true:
		Server.token = token
		Server.ConnectToServer()
		#Server.FetchPlayerStats()
		
	else:
		print("Login Failed -- Please provide a valid username and password")
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_button.disabled = false
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
	
# warning-ignore:unused_argument
remote func ReturnCreateAccountRequest(valid_request, message):
	#1 = failed to create, 2 = username already in use, 3 = account created successfully
	if message == 1:
		emit_signal("close_account_screen_signal")
	elif message == 2:
		pass
	elif message == 3:
		pass
		
		print("Account Created")
	
		
