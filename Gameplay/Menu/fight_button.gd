extends Button

@export var fight_data: FightData
@onready var sprite: TextureRect = $Control/TextureRect
#@onready var rank_text: RichTextLabel = $"Rank Text"
@onready var overlay: ColorRect = $Control
var unlocked: bool = false
var number: int = 0

signal fight_button_pressed(enemy: PackedScene)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalHub.refresh_unlocks.connect(refresh_unlock)
	refresh_unlock()
	sprite.texture = fight_data.fighter_sprite
	
func refresh_unlock() -> void:
	number = fight_data.fight_number
	unlocked = PlayerData.fights_unlocked[number]
	disabled = !unlocked
	overlay.color = Color.from_rgba8(0,0,0,150) if disabled else Color.TRANSPARENT
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
	PlayerData.current_fight_num = number
	fight_button_pressed.emit(fight_data.enemy_scene)

var default_scale := Vector2(1,1)
var scaled_up := Vector2(1.1,1.1)

var button_tween: Tween
var scale_tween: Tween

func tween_scale_to(scale_to: Vector2) -> void:
	if scale_tween:
		scale_tween.stop()
	scale_tween = create_tween()
	scale_tween.tween_property(sprite, "scale", scale_to, 0.1).set_ease(Tween.EASE_OUT)
	
func tween_button_to(color: Color) -> void:
	if button_tween:
		button_tween.stop()
	button_tween = create_tween()
	button_tween.tween_property(self, "self_modulate", color, 0.1).set_ease(Tween.EASE_OUT)

func _on_mouse_entered() -> void:
	if disabled:
		return
	tween_scale_to(scaled_up)
	tween_button_to(Color.from_rgba8(0,0,0,65))


func _on_mouse_exited() -> void:
	if disabled:
		return
	tween_scale_to(default_scale)
	tween_button_to(Color.TRANSPARENT)
