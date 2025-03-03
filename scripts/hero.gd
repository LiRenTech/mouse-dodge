extends CharacterBody2D

var speed_size = 5
var target_location = Vector2(0, 0)
@onready var line = get_node("../Line2D")

func _ready() -> void:
	position = Vector2(1000, 500)
	
	pass


func _physics_process(delta: float) -> void:
	# 不断走向鼠标
	var target_vector = target_location - position
	target_vector = target_vector.normalized() * speed_size
	position += target_vector
	
	# 更新目标位置
	target_location = get_viewport().get_mouse_position()
	pass

func _process(delta: float) -> void:
	# 渲染鼠标连线
	line.points = [position, target_location]
	line.visible = (position.distance_to(target_location) > 10)
	pass
