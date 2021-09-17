extends Node

var X509_cert_filename = "X509_CertificateTEST.crt"
var X509_key_filename = "X509_KeyTEST.key"
onready var X509_cert_path = "user://Certificate/" + X509_cert_filename
onready var X509_key_path = "user://Certificate/" + X509_key_filename

export var CN = "MultiplayerTutorial"
export var O  = "ShakaGames"
export var C = "AU"
export var not_before = "20201023000000"
export var not_after = "20221023000000"

func _ready():
	var directory = Directory.new()
	if not directory.dir_exists("user://Certificate/"):
		directory.make_dir("user://Certificate/")
	CreateX509Cert()
	print("Certificate Created at: " + "user://Certificate/")
	
func CreateX509Cert():
	randomize()
	var CNOC = "CN=" + CN + ",O=" + O + ",C=" + C
	var crypto = Crypto.new()
	var crypto_key = crypto.generate_rsa(4096)
	var X509_cert = crypto.generate_self_signed_certificate(crypto_key, CNOC, not_before, not_after)
	X509_cert.save(X509_cert_path)
	crypto_key.save(X509_key_path)
	print("done")
