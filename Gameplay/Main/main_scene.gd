extends TextureRect

@onready var gradient: TextureRect = $ColorRect
@onready var get_hit_sound: AudioStreamPlayer = $GetHitSound
@onready var block_sound: AudioStreamPlayer = $BlockSound
@onready var miss_sound: AudioStreamPlayer = $MissSound

func _input(event: InputEvent) -> void:
	var main_menu := load("res://Gameplay/Menu/main_menu.tscn")
	if event.is_action_pressed("menu"):
		get_tree().change_scene_to_packed(main_menu)
		queue_free()
		
func _ready() -> void:
	SignalHub.player_fail_attack.connect(on_fail_attack)
	SignalHub.player_success_block.connect(on_block)
	SignalHub.enemy_hit_damage.connect(on_get_hit)

func flash_gradient(color: Color) -> void:
	var trans_tween: Tween = create_tween()
	gradient.self_modulate = color
	trans_tween.tween_property(gradient, "modulate", Color.WHITE, 0.1)
	trans_tween.tween_property(gradient, "modulate", Color.TRANSPARENT, 0.1)

func on_get_hit() -> void:
	get_hit_sound.play()
	flash_gradient(Color.RED)
	
func on_block() -> void:
	block_sound.play()
	flash_gradient(Color.BLUE)
	
func on_fail_attack() -> void:
	miss_sound.play()
	flash_gradient(Color.YELLOW)
