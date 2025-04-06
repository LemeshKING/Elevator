extends CharacterBody2D

@export var attack_damage := 10
@export var attack_cooldown := 1.5
@export var attack_charge = 0.5
var can_attack := true
var attack_charged := false

var player: CharacterBody2D = null
const SPEED = 150.0
const FALLING_SPEED = 500.0
const ATTACK_RANGE = 32
signal died()

var health = 30

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$CollisionShape2D.set_deferred("disabled", false)
	$AnimatedSprite2D.play("Idle")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	$AttackArea.body_entered.connect(_on_attack_connect)
	$AttackCD.wait_time = attack_cooldown
	$AttackCD.timeout.connect(_reset_attack)
	$ChargeAttack.wait_time = attack_charge
	$ChargeAttack.timeout.connect(chargeAttack)
	
func take_damage(amount):
	health -= amount
	if health <= 0:
		die()
		emit_signal("died")
	
func die():

	queue_free()

func _on_attack_connect(body):
	if body.name == "Player" and can_attack:
		if body.has_method("takeDamage"):
			body.takeDamage(attack_damage) 
			attack_charge = false
			can_attack = false
			$AttackCD.start()

func _reset_attack():
	can_attack = true

func chargeAttack():
	attack_charge = true

func _physics_process(delta: float) -> void:


	var distance_x = 0.0
	var distance_y = 0.0
	# Движение к игроку (если он существует)
	if player:
		var direction_to_player_x = ((player.global_position.x - 32)- global_position.x) / abs((player.global_position.x - 32)  - global_position.x)
		var direction_to_player_y = (player.global_position.y - global_position.y) / abs(player.global_position.y  - global_position.y)
		distance_y = abs(player.global_position.y - global_position.y)
		distance_x = abs((player.global_position.x + 5) - global_position.x)
		
		if direction_to_player_x > 0:
			distance_x =  abs((player.global_position.x - 5) - global_position.x)
			
			$AnimatedSprite2D.flip_h = 0
		else:
			$AttackArea.position.x = -80
			$AnimatedSprite2D.flip_h = -1
		if sqrt(distance_x * distance_x + distance_y * distance_y) > ATTACK_RANGE:
			velocity.y = direction_to_player_y * FALLING_SPEED
			if position.y > 300:
				velocity.x = direction_to_player_x * SPEED
				velocity.y = direction_to_player_y * SPEED
			
			if distance_y < 10:
				velocity.y = 0
		else:
			velocity.x = 0
			velocity.y = 0
	move_and_slide()
