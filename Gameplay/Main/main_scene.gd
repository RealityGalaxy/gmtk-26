extends TextureRect

@onready var gradient: TextureRect = $ColorRect
@onready var get_hit_sound: AudioStreamPlayer = $GetHitSound
@onready var block_sound: AudioStreamPlayer = $BlockSound
@onready var miss_sound: AudioStreamPlayer = $MissSound
@onready var VBOX: VBoxContainer = $VBox
@export var player: PackedScene

func _ready() -> void:
	var enemy: VBoxContainer = PlayerData.enemy.instantiate()
	enemy.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var player_node: Control = player.instantiate()
	player_node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	VBOX.add_child(enemy)
	VBOX.add_child(player_node)
	SignalHub.player_fail_attack.connect(on_fail_attack)
	SignalHub.player_success_block.connect(on_block)
	SignalHub.enemy_hit_damage.connect(on_get_hit)
	SignalHub.enemy_died.connect(game_end)
	SignalHub.player_died.connect(game_end)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		go_to_main_menu()
		
func go_to_main_menu() -> void:
	var main_menu := load("res://Gameplay/Menu/main_menu.tscn")
	get_tree().change_scene_to_packed(main_menu)
	queue_free()

@onready var game_over_screen: ColorRect = $"Game Over Screen"
@onready var game_over_content: Control = $"Game Over Screen/Game Over Content"
@onready var game_over_text: RichTextLabel = $"Game Over Screen/Game Over Content/Game Over Text"
@onready var timer: Timer = $Timer
  
func game_end() -> void:
	SignalHub.game_pause.emit()
	create_tween().tween_property(music_player, "volume_db", -35, 0.5).set_ease(Tween.EASE_IN)
	timer.stop()

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

var intro_done: bool = false

@export var loop_sound: AudioStream
@onready var music_player: AudioStreamPlayer = $MusicPlayer

func _on_audio_stream_player_finished() -> void:
	if !intro_done:
		music_player.stream = loop_sound
		intro_done = true
	music_player.play()


func _on_game_over_screen_go_back_button() -> void:
	go_to_main_menu()
