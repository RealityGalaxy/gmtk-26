extends Button

@export var fight_data: FightData
@onready var sprite: TextureRect = $Control/TextureRect
@onready var rank_text: RichTextLabel = $"Rank Text"
var unlocked: bool = false
var number: int = 0

signal fight_button_pressed(enemy: PackedScene)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	number = fight_data.fight_number
	unlocked = PlayerData.fights_unlocked[number]
	sprite.texture = fight_data.fighter_sprite
	self.disabled = !unlocked
	rank_text.text = "[b][i]" + PlayerData.fight_ranks[number]
	rank_text.add_theme_color_override("default_color", rank_to_color(PlayerData.fight_ranks[number]))
	sprite.self_modulate = Color.BLACK if !unlocked else Color.WHITE

func rank_to_color(rank: String) -> Color:
	match rank:
		"S":
			return Color.DARK_ORANGE
		"A":
			return Color.GREEN
		"B":
			return Color.BLUE
		"C":
			return Color.PURPLE
		"D":
			return Color.FIREBRICK
		_:
			return Color.WHITE


func _on_pressed() -> void:
	fight_button_pressed.emit(fight_data.enemy_scene)
