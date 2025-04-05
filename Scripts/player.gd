extends CharacterBody2D

var attack_damage := 10
var attack_cooldown := 0.5


const SPEED = 300.0

var can_attack := true
var enemies_in_range = []

signal attack_landed(enemy)

func _ready():
	$PlayerAnimation.play("Idle")
	if not $AttackArea.is_connected("body_entered", _on_attack_area_body_entered):
		$AttackArea.connect("body_entered", _on_attack_area_body_entered)
	if not $AttackArea.is_connected("body_exited", _on_attack_area_body_exited):
		$AttackArea.connect("body_exited", _on_attack_area_body_exited)

func _input(event):
	if event.is_action_pressed("ui_accept") and can_attack:
		perform_attack()

func perform_attack():
	if not can_attack: return
	can_attack = false
	for enemy in enemies_in_range:
		if enemy.has_method("take_damage"):
			enemy.take_damage(attack_damage)
			emit_signal("attack_landed", enemy)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	

	# Handle jump.



	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var directionX := Input.get_axis("ui_left", "ui_right")
	if directionX:
		velocity.x = directionX * SPEED
		$AttackArea.scale.x = sign(directionX)
		$AttackArea.position.x = abs(64) * sign(directionX)
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	var directionY := Input.get_axis("ui_up","ui_down")
	if directionY:
		velocity.y = directionY * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)
	move_and_collide(velocity * delta)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Mobs"):
		enemies_in_range.append(body)


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body in enemies_in_range:
		enemies_in_range.erase(body)
