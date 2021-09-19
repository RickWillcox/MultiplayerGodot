extends KinematicBody2D

var icespear = preload("res://Scenes/Player/IceSpear.tscn")
var attack_dict = {} #{"Position": position, "AnimationVector": animation_vector}
var state = "Idle"

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")

func _physics_process(delta):
	if not attack_dict == {}:
		Attack()

func _ready():
	randomize()
	var random_color = Color(randf(), randf(), randf())
	get_node("Sprite").modulate = random_color

func MovePlayer(new_position, animation_vector):
	if state != "Attack":
		animation_tree.set('parameters/Walk/blend_position', animation_vector)
		animation_tree.set('parameters/Idle/blend_position', animation_vector)
		if new_position == position:
			state = "Idle"
			animation_mode.travel("Idle")
		else:
			state = "Walk"
			animation_mode.travel("Walk")
			set_position(new_position)

func Attack():
	for attack in attack_dict.keys():
		if attack <= Server.client_clock:
			state = "Attack_Spell"
			animation_tree.set('parameters/Attack_Spell/blend_position', attack_dict[attack]["AnimationVector"])
			animation_mode.travel("Attack_Spell")
			set_position(attack_dict[attack]["Position"])
			
			get_node("TurnAxis").rotation = get_angle_to(position + attack_dict[attack]["AnimationVector"])
			var icespear_instance = icespear.instance()
			print(str(attack_dict[attack]["AnimationVector"]) + " " + str(position))
			icespear_instance.impulse_rotation = get_angle_to(position + attack_dict[attack]["AnimationVector"])
			icespear_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
			icespear_instance.direction = attack_dict[attack]["AnimationVector"]	
			icespear_instance.original = false
			attack_dict.erase(attack)
			yield(get_tree().create_timer(0.4), "timeout")
			get_parent().add_child(icespear_instance)
			yield(get_tree().create_timer(0.4), "timeout")
			
			state = "Idle"
