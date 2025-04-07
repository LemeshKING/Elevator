extends CharacterBody2D

signal health_updated(current_hp, max_hp)

enum {STAY, RUN, CHARGE, ATTACK}
var current_state = STAY
@export var max_health := 100
var current_health := max_health:
	set(value):
		current_health = clamp(value, 0, max_health)
		health_updated.emit(current_health, max_health)

var attack_damage := 30
var attack_cooldown := 0.5


const SPEED = 450.0

var can_attack := true
var enemies_in_range = []

signal attack_landed(enemy)

func _ready():
	$PlayerAnimation.play("Run")
	if not $AttackArea.is_connected("body_entered", _on_attack_area_body_entered):
		$AttackArea.connect("body_entered", _on_attack_area_body_entered)
	if not $AttackArea.is_connected("body_exited", _on_attack_area_body_exited):
		$AttackArea.connect("body_exited", _on_attack_area_body_exited)
	$PlayerAnimation.sprite_frames.set_animation_loop("Attack", false)
	$PlayerAnimation.sprite_frames.set_animation_loop("Charge", false)
	$Decay.wait_time = 1
	$Decay.start()


func _input(event):

	if current_state == STAY and (event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down")):
		current_state = RUN
	elif event.is_action_pressed("ui_accept") and can_attack:
		current_state = CHARGE


func perform_attack():
	if not can_attack: return
	can_attack = false
	for enemy in enemies_in_range:
		if enemy.has_method("take_damage"):
			enemy.take_damage(attack_damage)
			emit_signal("attack_landed", enemy)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func takeDamage(amount):
	current_health -= amount
	if(current_health >= max_health):
		current_health = max_health
	if(current_health <= 0):
		die()

func die():
	get_tree().call_group("Mobs", "queue_free")
	get_tree().call_group("acid", "queue_free")
	get_tree().change_scene_to_file("res://Scenes/death_menu.tscn")

func _process(delta: float) -> void:
	_state_machine()

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var directionX := Input.get_axis("ui_left", "ui_right")
	if directionX > 0:
		$PlayerAnimation.flip_h = 0
		$AttackArea.position.x  = 55
	elif directionX < 0:
		$PlayerAnimation.flip_h = -1
		$AttackArea.position.x = 0
	if current_state == RUN:
		if directionX:
			velocity.x = directionX * SPEED
			$AttackArea.scale.x = sign(directionX)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		var directionY := Input.get_axis("ui_up","ui_down")
		if directionY:
			velocity.y = directionY * SPEED
		else:
			velocity.y = move_toward(velocity.x, 0, SPEED)
		move_and_slide()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Mobs"):
		enemies_in_range.append(body)


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body in enemies_in_range:
		enemies_in_range.erase(body)


func _on_decay_timeout() -> void:
	takeDamage(1)
	$Decay.start() 
	
func _state_machine():
	if current_state == STAY:
		$PlayerAnimation.play("Stay")
	elif current_state == RUN:
		$PlayerAnimation.play("Run")
		var tmp = Input.get_axis("ui_left", "ui_right")
		var tmp1 = Input.get_axis("ui_up", "ui_down")
		if tmp == 0 and tmp1 == 0:
			current_state = STAY
	elif current_state == CHARGE:
		$PlayerAnimation.play("Charge")
		await  $PlayerAnimation.animation_finished
		current_state = ATTACK
	else:
		$PlayerAnimation.play("Attack")
		await $PlayerAnimation.animation_finished
		perform_attack()
		current_state = STAY
