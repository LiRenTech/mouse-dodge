# MusicController.gd
extends Node2D

# 预加载两个音乐资源（需在属性面板设置路径）
@export var track1: AudioStream
@export var track2: AudioStream

# 创建音频播放节点
@onready var player = $AudioStreamPlayer

func _ready():
	player.stream = track1  # 默认加载第一首
	player.play()

# 核心功能函数
func play_music(track_num: int):
	player.stop()
	match track_num:
		1: player.stream = track1
		2: player.stream = track2
	if track_num == 2:
		player.volume_db = 5.0  # 第二首音乐音量调高
	else:
		player.volume_db = 0
	player.play()

func stop():
	player.stop()

func set_volume(db: float):
	player.volume_db = db

func toggle_pause():
	player.stream_paused = !player.stream_paused
