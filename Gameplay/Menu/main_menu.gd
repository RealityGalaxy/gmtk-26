extends TextureRect

@onready var currently_visible: Control = $"Main Screen"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		_on_back_button_pressed()

var fight_scene: PackedScene = preload("res://Gameplay/Main/main_scene.tscn")
@export var tutorial_enemy: PackedScene

func _on_fight_pressed() -> void:
	if PlayerData.tutorial_done:
		PlayerData.in_tutorial = false
		currently_visible.visible = false
		currently_visible = $"Fights Screen"
		currently_visible.visible = true
	else:
		PlayerData.in_tutorial = true
		_on_fight_started(tutorial_enemy)
	
func _on_fight_started(enemy: PackedScene) -> void:
	PlayerData.enemy = enemy
	get_tree().root.add_child(fight_scene.instantiate())
	queue_free()


func _on_back_button_pressed() -> void:
	currently_visible.visible = false
	currently_visible = $"Main Screen"
	currently_visible.visible = true


func _on_traits_pressed() -> void:
	currently_visible.visible = false
	currently_visible = $"Traits Screen"
	currently_visible.visible = true


func _on_main_screen_settings_pressed() -> void:
	currently_visible.visible = false
	currently_visible = $Settings
	currently_visible.visible = true
