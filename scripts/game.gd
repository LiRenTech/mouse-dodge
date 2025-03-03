extends Node2D

@onready var hero = get_node("CanvasLayer/Hero")
@onready var canvas = get_node("CanvasLayer")

var stone_scene = preload("res://scenes/stone.tscn")
var explode_scene = preload("res://scenes/explode.tscn")
var part_scene = preload("res://scenes/part.tscn")
var boots_scene = preload("res://scenes/boots.tscn")

enum GameState {
	PLAYING,
	GAME_OVER
}


var game_data = {
	"collect_count": 0,
	"stage": GameState.PLAYING,
	"hard": 0.0,  # 当前难度系数，0~1
}

func _ready() -> void:
	print("ready")
	game_data["stage"] = GameState.PLAYING
	# 一开始还看不到结束标志
	$CanvasLayer/GameOverFrame.visible = false
	pass

func _physics_process(_delta: float) -> void:
	# 每时每秒都向舞台添加陨石
	generate_stone()
	generate_part()
	generate_boots()
	pass

func _clear_all_entity() -> void:
	# 清理所有在场陨石
	var stone_group = get_tree().get_nodes_in_group("stone_group")
	for stone in stone_group:
		stone.queue_free()
	var part_group = get_tree().get_nodes_in_group("part_group")
	for part in part_group:
		part.queue_free()
	var boots_group = get_tree().get_nodes_in_group("boots_group")
	for boots in boots_group:
		boots.queue_free()

func game_over(dead_position: Vector2):
	print("game_over!", dead_position)
	game_data["stage"] = GameState.GAME_OVER
	# 创造一个爆炸
	var explode = explode_scene.instantiate()
	explode.position = dead_position
	canvas.add_child(explode)
	
	$Sounds/Collide.play()
	
	_clear_all_entity()
	# 显示结束画面
	$CanvasLayer/GameOverFrame.visible = true

func collect_part(collect_position: Vector2):
	print("collect!")
	game_data["collect_count"] += 1
	game_data["hard"] = game_data["collect_count"] / 100.0  # 必须写成小数，否则结果会转换成整数
	$CanvasLayer/GameDataUI/Debug.text = str(game_data)
	# sound
	$Sounds/Collect.pitch_scale = randf_range(0.6, 1.5)
	$Sounds/Collect.play()
	# 更新UI
	$CanvasLayer/GameDataUI/PartCount.text = str(game_data["collect_count"]) + "/100"
	if game_data["collect_count"] >= 100:
		print("congratulation!")
		_clear_all_entity()
	pass


func add_speed(collect_position: Vector2):
	print("add_speed!")
	hero.speed_size += 1

func generate_stone():
	if game_data["stage"] != GameState.PLAYING:
		return
	# 出现率随难度系数的增加而增加
	var rate = 0.001 + game_data["hard"] * 0.05
	if !(randf() < rate):
		return
	var stone = stone_scene.instantiate()
	stone.add_to_group("stone_group")
	canvas.add_child(stone)
	stone.connect("hero_collide_with_stone_signal", Callable(self, "game_over"))
	
	stone.position = get_random_edge_position(50)
	# 计算朝向英雄的方向
	var direction = (hero.position - stone.position).normalized()
	
	# 设置陨石速度
	var speed_random_mid = game_data["hard"] * 400 + 100
	stone.speed = direction * randf_range(
		speed_random_mid - 50, 
		speed_random_mid + 50
		)
	stone.scale *= randf_range(0.2, 2)
	pass

func generate_part():
	if game_data["stage"] != GameState.PLAYING:
		return
	var rate = 0.05 + (-0.04) * game_data["hard"]  # 难度系数越高，越少生成
	if !(randf() < rate):
		return
	var part = part_scene.instantiate()
	part.position = get_random_edge_position()
	part.connect("hero_collide_with_part_signal", Callable(self, "collect_part"))
	canvas.add_child(part)
	part.add_to_group("part_group")
	var direction = (hero.position - part.position).normalized()
	part.speed = direction * randf_range(100, 500)

func generate_boots():
	if game_data["stage"] != GameState.PLAYING:
		return
	var rate = 0.005
	if !(randf() < rate):
		return
	var boots = boots_scene.instantiate()
	boots.position = get_random_edge_position()
	boots.connect("hero_collide_with_boots_signal", Callable(self, "add_speed"))
	canvas.add_child(boots)
	boots.add_to_group("boots_group")
	var direction = (hero.position - boots.position).normalized()
	boots.speed = direction * randf_range(50, 100)


func get_random_edge_position(margin: int = 0) -> Vector2:
	# 设置陨石生成位置在屏幕外的随机边缘
	var viewport_rect = get_viewport().get_visible_rect()
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
