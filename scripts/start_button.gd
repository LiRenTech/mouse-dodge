extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_button_pressed():
	Music.play_music(2)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
