extends Node2D

@onready var hero = get_node("CanvasLayer/Hero")
@onready var canvas = get_node("CanvasLayer")

var stone_scene = preload("res://scenes/stone.tscn")
var explode_scene = preload("res://scenes/explode.tscn")

enum GameState {
	PLAYING,
	GAME_OVER
}

var game_state = GameState.PLAYING

func _ready() -> void:
	print("ready")
	game_state = GameState.PLAYING
	# 一开始还看不到结束标志
	$CanvasLayer/GameOverFrame.visible = false
	pass

func _physics_process(_delta: float) -> void:
	# 每时每秒都向舞台添加陨石
	#print(hero.position)
	generate_stone()
	pass

func game_over(dead_position: Vector2):
	print("game_over!", dead_position)
	game_state = GameState.GAME_OVER
	# 创造一个爆炸
	var explode = explode_scene.instantiate()
	explode.position = dead_position
	canvas.add_child(explode)
	
	# 清理所有在场陨石
	var stone_group = get_tree().get_nodes_in_group("stone_group")
	for stone in stone_group:
		stone.queue_free()
	# 显示结束画面
	$CanvasLayer/GameOverFrame.visible = true

func generate_stone():
	if game_state != GameState.PLAYING:
		return
	if randf() > 0.05:
		return
	var stone = stone_scene.instantiate()
	stone.add_to_group("stone_group")
	canvas.add_child(stone)
	stone.connect("hero_collide_with_stone_signal", Callable(self, "game_over"))
	stone.position = get_random_edge_position()
	# 计算朝向英雄的方向
	var direction = (hero.position - stone.position).normalized()
	
	# 设置陨石速度
	stone.speed = direction * randf_range(100, 500)
	stone.scale *= randf_range(0.2, 2)
	pass

func get_random_edge_position() -> Vector2:
	# 设置陨石生成位置在屏幕外的随机边缘
	var viewport_rect = get_viewport().get_visible_rect()
	var margin = 0  # 屏幕外间距
	var edge = randi() % 4  # 随机选择四个边
	
	var spawn_pos = Vector2()
	match edge:
		0: # 左边缘
			spawn_pos = Vector2(-margin, randf_range(margin, viewport_rect.size.y - margin))
		1: # 右边缘
			spawn_pos = Vector2(viewport_rect.size.x + margin, randf_range(margin, viewport_rect.size.y - margin))
		2: # 上边缘
			spawn_pos = Vector2(randf_range(margin, viewport_rect.size.x - margin), -margin)
		3: # 下边缘
			spawn_pos = Vector2(randf_range(margin, viewport_rect.size.x - margin), viewport_rect.size.y + margin)
	return spawn_pos


func _on_button_pressed() -> void:
	# 用户点击结束游戏，回到主界面
	get_tree().change_scene_to_file("res://scenes/home.tscn")
	pass # Replace with function body.
