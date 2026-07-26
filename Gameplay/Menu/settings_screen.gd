extends MarginContainer

signal on_back_button_pressed()

func _on_back_pressed() -> void:
	on_back_button_pressed.emit()


func _on_unlock_pressed() -> void:
	PlayerData.fights_unlocked = [true, true, true]
	PlayerData.fights_won = [true, true, true]
	
	SignalHub.refresh_unlocks.emit()


func _on_reset_pressed() -> void:
	PlayerData.fights_unlocked = [true, false, false]
	PlayerData.fights_won = [false, false, false]
	
	SignalHub.refresh_unlocks.emit()
