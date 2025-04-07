extends CharacterBody2D

enum { RUN, CHARGE, ATTACK, STAY}

@export var attack_damage := 10
@export var attack_cooldown := 1.0
@export var attack_charge = 1.0

var can_attack := true
var attack_charged := false
var attack_timer = 0.0

var player_in_attack_area = false
var direction_to_player_x = 1
var player: CharacterBody2D = null
const SPEED = 150.0
const FALLING_SPEED = 500.0
const ATTACK_RANGE = 64.5
signal died()
var current_state = RUN
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
	$AnimatedSprite2D.sprite_frames.set_animation_loop("AttackCharge", false)
	$AnimatedSprite2D.sprite_frames.set_animation_loop("Attack", false)

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()
		emit_signal("died")
	
func die():
	queue_free()

func _on_attack_connect(body):
	if body.name == "Player":
		player_in_attack_area = true

func _reset_attack():
	can_attack = true

func chargeAttack():
	attack_charge = true

func _process(delta: float) -> void:
	_change_state()
	if current_state == CHARGE:
		attack_timer += delta

func _physics_process(delta: float) -> void:


	var distance_x = 0.0
	var distance_y = 0.0
	# Движение к игроку (если он существует)
	if player and current_state == RUN:
		if abs((player.global_position.x - 80) - global_position.x) > ATTACK_RANGE - 5:
			direction_to_player_x = ((player.global_position.x - 80)- global_position.x) / abs((player.global_position.x - 80)  - global_position.x)
		var direction_to_player_y = (player.global_position.y - global_position.y) / abs(player.global_position.y  - global_position.y)
		distance_y = abs(player.global_position.y - global_position.y)
		distance_x = abs((player.global_position.x + 5) - global_position.x)
		
		if direction_to_player_x > 0:
			distance_x =  abs((player.global_position.x - 5) - global_position.x)
			
			$AnimatedSprite2D.flip_h = -1
			$AttackArea.position.x = 64.5
		else:
	
			$AttackArea.position.x = -64.5
			$AnimatedSprite2D.flip_h = 0
		if sqrt(distance_x * distance_x + distance_y * distance_y) > ATTACK_RANGE:
			velocity.y = direction_to_player_y * FALLING_SPEED
			if position.y > 300:
				if distance_x > 17:
					velocity.x = direction_to_player_x * SPEED
				velocity.y = direction_to_player_y * SPEED
			
			if distance_y < 17:
				velocity.y = 0
		else:
			velocity.x = 0
			velocity.y = 0
		move_and_slide()



func _attackPlayer():
	player.takeDamage(attack_damage)
	can_attack = false
	$AttackCD.start()
	attack_timer = 0

func _change_state():
	if current_state == RUN and not player_in_attack_area:
		$AnimatedSprite2D.play("Idle")
	elif current_state == RUN and can_attack:
		current_state = CHARGE
		$AnimatedSprite2D.play("AttackCharge")
		attack_timer = 0
	elif current_state == CHARGE and attack_timer > attack_charge:
		current_state = ATTACK
		$AnimatedSprite2D.play("Attack")
	elif current_state == ATTACK:
		current_state = RUN
		if player_in_attack_area:
			_attackPlayer()
			current_state = STAY
	elif current_state == STAY:
		$AnimatedSprite2D.play("Idle")
		if player_in_attack_area and can_attack:
			$AnimatedSprite2D.play("AttackCharge")
			current_state = CHARGE
		elif not player_in_attack_area:
			current_state = RUN
			


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_attack_area = false
