extends VBoxContainer

signal fight_pressed()
signal traits_pressed()
signal settings_pressed()

func _on_fight_pressed() -> void:
	fight_pressed.emit()


func _on_traits_pressed() -> void:
	traits_pressed.emit()


func _on_settings_pressed() -> void:
	settings_pressed.emit()
