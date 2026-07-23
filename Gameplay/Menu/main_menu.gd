extends TextureRect

@onready var currently_visible: Control = $"Main Screen"
@onready var default_visible: Control = $"Main Screen"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var fight_scene: PackedScene = preload("res://Gameplay/Main/main_scene.tscn")

func _on_fight_pressed() -> void:
	get_tree().root.add_child(fight_scene.instantiate())
	queue_free()


func _on_back_button_pressed() -> void:
	currently_visible.visible = false
	currently_visible = default_visible
	default_visible.visible = true


func _on_traits_pressed() -> void:
	currently_visible.visible = false
	currently_visible = $"Traits Screen"
	currently_visible.visible = true
