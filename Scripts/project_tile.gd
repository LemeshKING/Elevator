extends Area2D


var speed = 400.0
var direction = Vector2.RIGHT
var damage = 10

func _ready():
	$LifeTime.timeout.connect(_on_lifetime_ended)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.name == "Player":
		if body.has_method("takeDamage"):
			body.takeDamage(damage)
			queue_free()

func _on_lifetime_ended():
	queue_free()
