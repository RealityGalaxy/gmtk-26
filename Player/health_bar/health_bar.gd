class_name HealthBar
extends ProgressBar

@onready var health_label: RichTextLabel = $"Health Label"
@export var drain_rate: float = 1
@export var bar_update_rate: float = 15

var target_value: float

func _ready() -> void:
	if PlayerData.in_tutorial:
		self.visible = false

func setup_health(max_hp: float) -> void:
	max_value = max_hp
	target_value = max_hp
	value = max_hp
	update_label()

func update_health(delta_hp: float) -> void:
	if !PlayerData.in_tutorial:
		target_value = clamp(target_value + delta_hp, 0, max_value)
	
func update_label() -> void:
	if health_label:
		var new_text: String = str(snapped(value, 0.1)) + " / " + str(max_value)
		if PlayerData.attack_combo:
			new_text += " - " + str(snapped(PlayerData.combo_multiplier, 0.1))
		health_label.text = new_text

func _process(delta: float) -> void:
	value = lerpf(value, target_value, bar_update_rate * delta)
	update_label()
