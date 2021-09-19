extends RigidBody2D

onready var animation_tree = get_node("AnimationTree")

var despawn_timer = 4
var projectile_speed = 900
var damage 
var original = true #is it a player icespear? for onhit
var impulse_rotation
var direction

func _ready():
	Server.FetchSkillDamage("Ice Spear", get_instance_id())
	animation_tree.set('parameters/Direction/blend_position', direction)
	apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(impulse_rotation))	
	SelfDestruct()
	
func _physics_process(delta):
	pass

func SelfDestruct():
	yield(get_tree().create_timer(despawn_timer), "timeout")
	queue_free()

func _on_IceSpear_body_entered(body):
	get_node("CollisionPolygon2D").set_deferred("disabled", true)
	if body.is_in_group("Enemies") and original == true:
		body.on_hit(damage)
		$AudioStreamPlayer_Hit.play()
	self.hide()

func SetDamage(s_damage):
	
	damage = s_damage
	
