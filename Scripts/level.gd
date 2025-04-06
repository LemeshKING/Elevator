extends Node2D

@export var enemy_scene: PackedScene
@export var range_enemy_scene: PackedScene
@export var spawn_interval := 5.0


func _ready():
	$Timer.wait_time = spawn_interval
	$Timer.start()

func _on_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.global_position = Vector2(randf_range(0, 1000), 0) 
	enemy.add_to_group("Mobs")
	get_parent().add_child(enemy)
