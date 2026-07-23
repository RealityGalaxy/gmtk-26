extends TextureRect

func _input(event: InputEvent) -> void:
	var main_menu := load("res://Gameplay/Menu/main_menu.tscn")
	if event.is_action_pressed("menu"):
		get_tree().change_scene_to_packed(main_menu)
		queue_free()
