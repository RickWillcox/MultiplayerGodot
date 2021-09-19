extends RigidBody2D

var despawn_timer = 4
var projectile_speed = 900
var damage 
var impulse_rotation
var direction
var player_id

func _ready():
	apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(impulse_rotation))	
	SelfDestruct()
	get_node("CollisionPolygon2D").set_rotation(impulse_rotation)
	

func SelfDestruct():
	yield(get_tree().create_timer(despawn_timer), "timeout")
	queue_free()

func _on_IceSpear_body_entered(body):
	get_node("CollisionPolygon2D").set_deferred("disabled", true)
#	if body.is_in_group("Enemies") and original == true:
#		body.on_hit(damage)
#		$AudioStreamPlayer_Hit.play()
	self.hide()

#func SetDamage(s_damage):
#
#	damage = s_damage
	
