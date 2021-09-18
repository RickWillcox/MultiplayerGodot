extends KinematicBody2D


func _ready():
	randomize()
	var random_color = Color(randf(), randf(), randf())
	get_node("Sprite").modulate = random_color

func MovePlayer(new_position):
	set_position(new_position)
