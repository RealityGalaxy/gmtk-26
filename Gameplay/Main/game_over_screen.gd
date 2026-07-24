extends ColorRect

signal go_back_button()

@onready var game_over_content: Control = $"Game Over Content"
@onready var game_over_text: RichTextLabel = $"Game Over Content/Game Over Text"

func _ready() -> void:
	SignalHub.enemy_died.connect(game_end.bind("Won"))
	SignalHub.player_died.connect(game_end.bind("Lost"))

func game_end(state: String) -> void:
	game_over_text.text = "You " + state
	var color_to: Color = Color.from_rgba8(0,0,0,230)
	create_tween().tween_property(self, "color", color_to, 0.5).set_ease(Tween.EASE_IN_OUT)
	game_over_content.visible = true

func _on_button_pressed() -> void:
	go_back_button.emit()
