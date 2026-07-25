extends MarginContainer

signal back_button_pressed()
signal fight_button_pressed(enemy: PackedScene)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	back_button_pressed.emit()
	
	


func _on_button_fight_button_pressed(enemy: PackedScene) -> void:
	fight_button_pressed.emit(enemy)
