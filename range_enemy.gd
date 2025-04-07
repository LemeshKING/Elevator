extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var attack_range := 10000.0 
@export var attack_cooldown := 2.0
@export var projectile_speed := 200.0

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var health = 30

var target = null
var can_attack = true

signal died()

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()
		emit_signal("died")
	
func die():
	queue_free()
	
func _ready() -> void:
	$AttackTimer.wait_time = attack_cooldown
	$AttackTimer.timeout.connect(_on_attack_cooldown_finished)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]
	$AnimatedSprite2D.sprite_frames.set_animation_loop("Attack", false)

func _physics_process(delta: float) -> void:
	if target:
		$AnimatedSprite2D.play("Attack")
		var direction = (target.global_position - global_position).normalized()
		if direction.x != 0:
			$AnimatedSprite2D.flip_h = direction.x > 0
		await $AnimatedSprite2D.animation_finished
		if global_position.distance_to(target.global_position) <= attack_range and can_attack:

			shoot_at_target(direction)
		
	velocity.x = 0

	move_and_collide(velocity * delta)

func shoot_at_target(direction: Vector2):
	if not projectile_scene or not can_attack: 
		return
	
	can_attack = false
	$AttackTimer.start()
	
	var projectile = projectile_scene.instantiate()
	projectile.direction = direction
	projectile.speed = projectile_speed
	projectile.position =  $ShootingPoint.global_position
	if direction.x > 0:
		projectile.position.x += 60
	projectile.rotation = direction.angle()
	get_parent().add_child(projectile)
	
func _on_attack_cooldown_finished():
	can_attack = true
