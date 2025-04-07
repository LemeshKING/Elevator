extends Area2D


var speed = 400.0
var direction = Vector2.RIGHT
var damage = 10
var player_on_asid = false 
var player = null

func _ready():
	$DamageTimer.wait_time = 1.0
	$DamageTimer.start()

func _physics_process(delta):
	pass

func _on_body_entered(body):
	if body.name == "Player":
		player = body
		player_on_asid = true

func _on_lifetime_ended():
	queue_free()


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_on_asid = false


func _on_damage_timer_timeout() -> void:
	if player and player_on_asid:
		player.takeDamage(damage)
		$DamageTimer.start()
