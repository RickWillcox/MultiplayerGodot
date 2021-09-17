extends KinematicBody2D


var hp 
export var max_hp = 100

func _ready():
	hp = max_hp
	$HealthBar.max_value = max_hp
	$HealthBar.value = hp
	$Rekt.visible = false

func _physics_process(delta):
	$HealthBar.value = hp
	

func on_hit(damage):
	print("enemy hit")
	if hp > 0:
		hp -= damage
		if hp <= 0:
			$AnimationPlayer.play("Death")
			$AudioStreamPlayer_Death.play()
			$Rekt.visible = true
			yield(get_tree().create_timer(0.1), "timeout")
			$Rekt.visible = false
			$HealthBar.visible = false
			rotation = 90
			position = get_position() + Vector2(-10,-8)
			yield(get_tree().create_timer(1.5), "timeout")
			self.queue_free()
		
		
		


