extends Button

@onready var title: RichTextLabel = $"MarginContainer/HBoxContainer/Text Box/Title"
@onready var desc: RichTextLabel = $"MarginContainer/HBoxContainer/Text Box/Description"
@onready var sprite: TextureRect = $"MarginContainer/HBoxContainer/Trait Icon"
@export var trait_data: TraitData
@export var unlocked_by_fight: int = 0
var unlocked := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalHub.refresh_unlocks.connect(refresh_unlock)
	refresh_unlock()
	button_pressed = PlayerData.player_traits.any(func(x: TraitData) -> bool: return x.title == trait_data.title)
	
func refresh_unlock() -> void:
	unlocked = PlayerData.fights_won[unlocked_by_fight]
	disabled = !unlocked
	sprite.modulate = Color.BLACK if !unlocked else Color.WHITE
	title.text = trait_data.title if unlocked else "Locked"
	desc.text = trait_data.description if unlocked else "Unlock by winning fight #" + str(unlocked_by_fight+1)
	

func _on_pressed() -> void:
	if button_pressed:
		PlayerData.player_traits.append(trait_data)
	else:
		PlayerData.player_traits.erase(trait_data)
