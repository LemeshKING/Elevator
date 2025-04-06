extends CanvasLayer

@onready var health_bar := $HpBar as ProgressBar

func _ready():
	# Получаем ссылку на игрока
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_updated.connect(update_health_bar)

func update_health_bar(current, max_hp):
	health_bar.max_value = max_hp
	health_bar.value = current
	
	# Плавная анимация
	var tween = create_tween()
	tween.tween_property(health_bar, "value", current, 0.3).set_trans(Tween.TRANS_SINE)
