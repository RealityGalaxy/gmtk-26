extends HSlider

# Change "Master" to "SFX" or "Music" if using a custom bus
@export var bus_name: String = "Master"

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	
	var current_db := AudioServer.get_bus_volume_db(bus_index)
	value = db_to_linear(current_db)


func _on_value_changed(new_value: float) -> void:
	var db_value := linear_to_db(new_value)
	AudioServer.set_bus_volume_db(bus_index, db_value)
	AudioServer.set_bus_mute(bus_index, new_value <= min_value)
