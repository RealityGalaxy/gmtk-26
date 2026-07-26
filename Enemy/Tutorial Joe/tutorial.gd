extends Control

enum FlashState {
	ATTACK,
	BLOCK,
	DAMAGED,
	VULNERABLE
}

enum EnemyState {
	DEFAULT,
	VULNERABLE
}

@onready var health_bar: HealthBar = $"VBoxContainer/Health Bar"
@onready var get_hit_sound: AudioStreamPlayer = $VBoxContainer/HitEnemySound
@onready var sprite: TextureRect = $"VBoxContainer/Enemy Image"

# --- stat exports ---
@export var timing_window_ms: float = 100
@export var damage: float = 6
@export var max_health: float = 150
@export var move_set: Array[MoveSequence] = []
@export var next_move_in: int = 5
@export var bpm: float = 130.0

# --- sprite exports ---
@export var idle_sprite: Resource
@export var attack_sprite: Resource
@export var vulnerable_sprite: Resource
@export var background_sprite: Resource
var current_idle_sprite: Resource

var current_state: EnemyState = EnemyState.DEFAULT

@export var tutorial_texts: Array[String] = []
@onready var text_box: RichTextLabel = $Panel/Dialogue
var current_text: int = 0

func _set_tutorial_text(number: int) -> void:
	var tween := create_tween()
	tween.tween_property(text_box, "text", "", 0.2)
	tween.tween_property(text_box, "text", tutorial_texts[min(number, tutorial_texts.size()-1)], 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerData.tutorial_done = true
	current_idle_sprite = idle_sprite
	if !PlayerData.in_tutorial:
		health_bar.setup_health(max_health)
	SignalHub.game_tick.connect(on_tick)
	SignalHub.player_attack.connect(on_player_attack)
	SignalHub.player_parry.connect(on_player_parry)
	SignalHub.game_pause.connect(func() -> void: game_paused=true)
	SignalHub.enemy_bpm.emit(bpm)
	SignalHub.background_set.emit(background_sprite)
	SignalHub.player_success_block.connect(register_block_hit)
	SignalHub.player_fail_attack.connect(reset_attacks_tutorial)
	SignalHub.player_fail_block.connect(reset_blocks_tutorial)
	_set_tutorial_text(0)
	
var progress_allowed := true
	
func next_dialogue() -> void:
	_set_tutorial_text(current_text+1)
	current_text += 1
	
func _input(event: InputEvent) -> void:
	if progress_allowed and event.is_action_pressed("next_dialogue"):
		next_dialogue()
		
	if trying_inputs:
		if event.is_action_pressed("attack"):
			attacks_used += 1
		
		if event.is_action_pressed("block"):
			blocks_used += 1
		
var trying_inputs := false
		
var attacks_used: int = 0
var blocks_used: int = 0
	
func on_player_parry(damage: float) -> void:
	health_bar.update_health(-damage)

var tutorial_ticks_pause := true

func reset_attacks_tutorial() -> void:
	attacks_hit = 0
	
func reset_blocks_tutorial() -> void:
	blocks_hit = 0

func on_tick() -> void:
	if !tutorial_ticks_pause:
		next_move_in -= 1
	get_tree().create_timer(0.2).timeout.connect(sprite_to_idle)
	if next_move_in == 0:
		execute_random_move()
	if !tutorial_ticks_pause:
		jiggle()
	
func jiggle() -> void:
	var start_post := sprite.offset_transform_position
	var tween := create_tween()
	tween.tween_property(sprite, "offset_transform_position", start_post+Vector2(0, 5), 0.05)
	tween.tween_property(sprite, "offset_transform_position", start_post-Vector2(0, 5), 0.05)
	tween.tween_property(sprite, "offset_transform_position", start_post, 0.05)
		
func sprite_to_idle() -> void:
	sprite.texture = current_idle_sprite
	
@onready var charge_sound: AudioStreamPlayer = $VBoxContainer/EnemyChargeSound

func execute_random_move() -> void:
	var move_sequence: MoveSequence = get_move_from_set()
	current_idle_sprite = move_sequence.move_sprite
	sprite.texture = move_sequence.move_sprite
	charge_sound.stream = move_sequence.charge_sound
	charge_sound.play()
	for move_data: MoveData in move_sequence.move_sequence:
		await do_move(move_data)
	next_move_in = randi_range(3, 6)
	current_idle_sprite = idle_sprite
	
func get_move_from_set() -> MoveSequence:
	var roll: float = randf()
	for move: MoveSequence in move_set:
		if roll <= move.move_odds:
			return move
		roll -= move.move_odds
		
	return move_set.pick_random()
	

var game_paused := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !game_paused and !PlayerData.in_tutorial:
		health_bar.update_health(-delta)
		if health_bar.target_value <= 0:
			SignalHub.enemy_died.emit()
	progress_tutorial()

@onready var next_label: Control = $Panel/Next

func set_manual_continue(flag: bool) -> void:
	progress_allowed = flag
	next_label.visible = flag
	
var attacks_hit := 0
var blocks_hit := 0
	
func register_block_hit() -> void:
	blocks_hit += 1
	
func progress_tutorial() -> void:
	if current_text == 1:
		set_manual_continue(false)
		SignalHub.allow_tutorial_inputs.emit(true)
		trying_inputs = true
		if attacks_used >= 3 and blocks_used >= 3:
			next_dialogue()
	if current_text == 2:
		set_manual_continue(true)
		SignalHub.allow_tutorial_inputs.emit(false)
	if current_text == 4:
		set_manual_continue(false)
		SignalHub.allow_tutorial_inputs.emit(true)
		SignalHub.start_metronome.emit()
		tutorial_ticks_pause = false
		move_set[0].move_odds = 1
		if attacks_hit >= 3:
			next_dialogue()
	if current_text == 5:
		move_set[0].move_odds = 0
		move_set[1].move_odds = 1
		if blocks_hit >= 3:
			next_dialogue()
	if current_text == 6:
		set_manual_continue(true)
		SignalHub.allow_tutorial_inputs.emit(false)
		SignalHub.stop_metronome.emit()
		tutorial_ticks_pause = true
		move_set[1].move_odds = 0
	if current_text == 7:
		set_manual_continue(false)
		if !timer_started:
			timer_started = true
			get_tree().create_timer(2).timeout.connect(func() -> void: SignalHub.enemy_died.emit())
		
var timer_started := false
	
func get_sprite_for_move(move: MoveData.Move) -> Resource:
	match move:
		MoveData.Move.ATTACK:
			return attack_sprite
		MoveData.Move.VULNERABLE:
			return vulnerable_sprite
		_:
			return current_idle_sprite

func do_move(move_data: MoveData) -> void:
	var move: MoveData.Move = move_data.move
	if !move_data.sprite_on_tick:
		await SignalHub.animation_tick_start
		sprite.texture = get_sprite_for_move(move)
		sprite.flip_h = move_data.sprite_flipped_h
	await SignalHub.game_tick
	sprite.flip_h = move_data.sprite_flipped_h
	match move:
		MoveData.Move.WAIT:
			pass
		MoveData.Move.ATTACK:
			attack()
		MoveData.Move.VULNERABLE:
			vulnerable()

func attack() -> void:
	flash(FlashState.ATTACK)
	SignalHub.enemy_attack.emit(damage)

func reset_vulnerable() -> void:
	if current_state == EnemyState.VULNERABLE:
		SignalHub.combo_reset.emit()
	current_state = EnemyState.DEFAULT

func vulnerable() -> void:
	current_state = EnemyState.VULNERABLE
	get_tree().create_timer(timing_window_ms / 1000.0).timeout.connect(reset_vulnerable)
	flash(FlashState.VULNERABLE)
	
	var current_time: float = Time.get_ticks_msec()
	if (current_time - last_attack_time) < timing_window_ms:
		take_damage()
		
	last_attack_time = -1
	last_attack_dmg = -1
	
var last_attack_time: float = -1
var last_attack_dmg: float = -1
var failed_attack_timer: SceneTreeTimer
	
func on_player_attack(hit_damage: float) -> void:
	if last_attack_time != -1:
		flash(FlashState.BLOCK)
		print_debug("player double attacked")
		SignalHub.player_fail_attack.emit()
		SignalHub.player_health_changed.emit(-damage)
		SignalHub.combo_reset.emit()
		return
	
	last_attack_time = Time.get_ticks_msec()
	last_attack_dmg = hit_damage * PlayerData.damage_dealt_mult
	
	if current_state == EnemyState.VULNERABLE:
		take_damage()
	else:
		failed_attack_timer = get_tree().create_timer(timing_window_ms/1000.0)
		failed_attack_timer.timeout.connect(punish_player)
		
func punish_player() -> void:
	flash(FlashState.BLOCK)
	print_debug("player attack missed")
	last_attack_time = -1
	SignalHub.player_health_changed.emit(-damage)
	SignalHub.player_fail_attack.emit()
		
func take_damage() -> void:
	get_hit_sound.play()
	print_debug("enemy took a hit")
	attacks_hit += 1
	if failed_attack_timer:
		failed_attack_timer.timeout.disconnect(punish_player)
		failed_attack_timer = null
	last_attack_time = -1
	health_bar.update_health(-last_attack_dmg)
	if PlayerData.attack_combo:
		SignalHub.combo_stack.emit()
	if PlayerData.time_steal > 0:
		SignalHub.player_health_changed.emit(last_attack_dmg*PlayerData.time_steal)
	last_attack_dmg = -1
	flash(FlashState.DAMAGED)
	current_state = EnemyState.DEFAULT

func flash(state: FlashState) -> void:
	var color: Color = state_to_color(state)
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate", color, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func state_to_color(state: FlashState) -> Color:
	match state:
		FlashState.BLOCK:
			return Color.ROYAL_BLUE
		FlashState.DAMAGED:
			return Color.DARK_RED
		FlashState.VULNERABLE:
			return Color.YELLOW
		_:
			return Color.WHITE
