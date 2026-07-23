class_name HealthBar
extends ProgressBar

@onready var health_label: RichTextLabel = $"Health Label"
@export var drain_rate: float = 1
@export var bar_update_rate: float = 15

var target_value: float

func setup_health(max_hp: float) -> void:
	max_value = max_hp
	target_value = max_hp
	value = max_hp
	update_label()

func update_health(delta_hp: float) -> void:
	target_value = clamp(target_value + delta_hp, 0, max_value)
	
func update_label() -> void:
	if health_label:
		health_label.text = str(snapped(value, 0.1)) + " / " + str(max_value)

func _process(delta: float) -> void:
	value = lerpf(value, target_value, bar_update_rate * delta)
	update_label()
