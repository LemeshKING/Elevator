extends Area2D

var player: CharacterBody2D = null
var attack_damage = 8
var bodies_inside = {}
var canHeal = true
var healCD = 1.0
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	$HealTime.wait_time = healCD

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.has_method("takeDamage") and canHeal:
			body.takeDamage(-attack_damage) 
			bodies_inside[body.get_instance_id()] = body
			canHeal = false
			$HealTime.start()
			player = body

func _process(delta: float) -> void:
	if player != null and canHeal:
		player.takeDamage(-attack_damage)
		canHeal = false
		$HealTime.start()


func is_body_still_inside(body):
	return body.get_instance_id() in bodies_inside


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null


func _on_heal_time_timeout() -> void:
	canHeal = true
