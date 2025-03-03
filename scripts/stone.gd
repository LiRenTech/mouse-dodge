extends Area2D

@export var speed: Vector2 = Vector2(2, 0)

signal hero_collide_with_stone_signal

func _physics_process(delta: float) -> void:
	position += speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		emit_signal("hero_collide_with_stone_signal", position)
		# 这个石头清理掉
		queue_free()
	pass # Replace with function body.
