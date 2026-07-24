extends Button

@onready var title: RichTextLabel = $"MarginContainer/HBoxContainer/Text Box/Title"
@onready var desc: RichTextLabel = $"MarginContainer/HBoxContainer/Text Box/Description"
@export var trait_data: TraitData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.text = trait_data.title
	desc.text = trait_data.description
	button_pressed = PlayerData.player_traits.any(func(x: TraitData) -> bool: return x.title == trait_data.title)

func _on_pressed() -> void:
	if button_pressed:
		PlayerData.player_traits.append(trait_data)
	else:
		PlayerData.player_traits.erase(trait_data)
