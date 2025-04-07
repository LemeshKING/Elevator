extends Node2D

@export var mini_boss: PackedScene
@export var enemy_scene: PackedScene
@export var range_enemy_scene: PackedScene
@export var spawn_interval := 1.5
var spawnMobs = true
var timer = 0
var range_pos = [Vector2(150.0, 400.0), Vector2(150.0, 600.0), Vector2(150.0, 800.0), Vector2(1800.0, 400.0), Vector2(1800.0, 600.0), Vector2(1800.0, 800.0)]
var range_pos_busy = []
var spawn_only_melee = false
var k = 0
func _ready():
	$Timer.wait_time = spawn_interval
	$Timer.start()
	$mini_boss_time_spawn.wait_time = 20
	$mini_boss_time_spawn.start()

func _on_timer_timeout() -> void:
	if spawnMobs:
		spawn_enemy()

func _process(delta: float) -> void:
	timer += delta
	if get_tree().get_nodes_in_group("Mobs").size() == 0 and timer > 25:
		get_tree().change_scene_to_file("res://Scenes/win_menu.tscn")

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.global_position = Vector2(randf_range(300, 900), 0)
	if randi() % 3 == 2 and not spawn_only_melee: 
		enemy = range_enemy_scene.instantiate()
		enemy.projectile_speed = 800
		var pos = range_pos[randi() % range_pos.size()] 
		if pos not in range_pos_busy:
			enemy.global_position = pos
			range_pos_busy.append(pos)
		elif range_pos_busy.size() >= 6:
			enemy = enemy_scene.instantiate()
			enemy.global_position = Vector2(randf_range(300, 1000), 0) 
			spawn_only_melee =  true
		else:
			var k = 0
			while range_pos[k] in range_pos_busy:
				k+= 1
			pos = range_pos[k]
			enemy.global_position = pos
			range_pos_busy.append(pos)

	enemy.tree_exiting.connect(
		func():
			var pos = enemy.global_position
			if pos in range_pos_busy:
				range_pos_busy.erase(pos)
				spawn_only_melee = false
			)
	enemy.add_to_group("Mobs")
	get_parent().add_child(enemy)
	


func _on_mini_boss_time_spawn_timeout() -> void:
	if spawnMobs:
		var enemy = mini_boss.instantiate()
		enemy.global_position = Vector2(randf_range(300, 900), 0)
		enemy.add_to_group("Mobs")
		get_parent().add_child(enemy)
		spawnMobs = false
