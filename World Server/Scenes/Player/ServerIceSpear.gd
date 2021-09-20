extends RigidBody2D

var despawn_timer = 4
var projectile_speed = 900
var damage 
var impulse_rotation
var direction
var player_id

func _ready():
	SetDamage()
	apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(impulse_rotation))	
	SelfDestruct()
	get_node("CollisionPolygon2D").set_rotation(impulse_rotation)
	
func SetDamage():
	damage = ServerData.skill_data["Ice Spear"].Damage ####Add modifiers here eg more damage for intelligence
	DamageMultipliers(damage)
	
func SelfDestruct():
	yield(get_tree().create_timer(despawn_timer), "timeout")
	queue_free()

func _on_IceSpear_body_entered(body):
	get_node("CollisionPolygon2D").set_deferred("disabled", true)
	if body.is_in_group("NPCEnemies"):
		var enemy_id = int(body.get_name())
		get_node ("/root/Server/Map").NPCHit(enemy_id, damage)
	self.hide()

# warning-ignore:unused_argument
# warning-ignore:shadowed_variable
# warning-ignore:unused_argument
func DamageMultipliers(damage):
	#damage multipliers here
	pass
