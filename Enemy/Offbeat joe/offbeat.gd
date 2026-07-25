extends VBoxContainer

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

@onready var health_bar: HealthBar = $"Health Bar"
@onready var get_hit_sound: AudioStreamPlayer = $HitEnemySound
@onready var sprite: TextureRect = $"Enemy Image"

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
var current_idle_sprite: Resource

var current_state: EnemyState = EnemyState.DEFAULT

var saved_foretell: Array[MoveData.Move] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	move_set[0].move_odds = 0.5
	move_set[1].move_odds = 0
	current_idle_sprite = idle_sprite
	health_bar.setup_health(max_health)
	SignalHub.game_tick.connect(on_tick)
	SignalHub.player_attack.connect(on_player_attack)
	SignalHub.player_parry.connect(on_player_parry)
	SignalHub.game_pause.connect(func() -> void: game_paused=true)
	tells_label.text = ""
	SignalHub.enemy_bpm.emit(bpm)
	
func on_player_parry(damage: float) -> void:
	health_bar.update_health(-damage)

func on_tick() -> void:
	sprite.flip_h = false
	next_move_in -= 1
	get_tree().create_timer(0.1).timeout.connect(sprite_to_idle)
	if next_move_in == 0:
		execute_random_move()
	jiggle()
	
var jiggled: bool = false

func jiggle() -> void:
	if jiggled:
		jiggled = false
		return
	var start_post := sprite.offset_transform_position
	var tween := create_tween()
	tween.tween_property(sprite, "offset_transform_position", start_post+Vector2(0, 5), 0.05)
	tween.tween_property(sprite, "offset_transform_position", start_post-Vector2(0, 5), 0.05)
	tween.tween_property(sprite, "offset_transform_position", start_post, 0.05)
	jiggled = true
		
func sprite_to_idle() -> void:
	sprite.texture = current_idle_sprite
	
@onready var charge_sound: AudioStreamPlayer = $EnemyChargeSound
@onready var tells_label: RichTextLabel = $Tells

func execute_random_move() -> void:
	var move_sequence: MoveSequence = get_move_from_set()
	current_idle_sprite = move_sequence.move_sprite
	sprite.texture = move_sequence.move_sprite
	charge_sound.stream = move_sequence.charge_sound
	charge_sound.play()
	current_move_name = move_sequence.move_name
	for move_data: MoveData in move_sequence.move_sequence:
		await do_move(move_data)
	next_move_in = randi_range(3, 6) * 2
	current_idle_sprite = idle_sprite
	current_move_name = ""
	saved_foretell.clear()

func get_move_from_set() -> MoveSequence:
	var roll: float = randf()
	for move: MoveSequence in move_set:
		if move.move_odds == 0:
			pass
		if roll <= move.move_odds:
			return move
		roll -= move.move_odds
		
	return move_set.pick_random()

var game_paused := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !game_paused:
		health_bar.update_health(-delta)
	if health_bar.target_value <= 90:
		move_set[0].move_odds = 0
		move_set[1].move_odds = 0.5
	if health_bar.target_value <= 0:
		SignalHub.enemy_died.emit()
	
func get_sprite_for_move(move: MoveData.Move) -> Resource:
	match move:
		MoveData.Move.ATTACK:
			return attack_sprite
		MoveData.Move.VULNERABLE:
			return vulnerable_sprite
		_:
			return current_idle_sprite
			
var current_move_name: String = ""

func do_move(move_data: MoveData) -> void:
	var move: MoveData.Move = move_data.move
	var actual_move := move
	if move == MoveData.Move.EXECUTE:
		actual_move = saved_foretell[move_data.foretell_order]
	if !move_data.sprite_on_tick:
		await SignalHub.animation_tick_start
		sprite.texture = get_sprite_for_move(actual_move)
		sprite.flip_h = move_data.sprite_flipped_h
	await SignalHub.game_tick
	sprite.flip_h = move_data.sprite_flipped_h
	tells_label.text = move_data.move_text
	match actual_move:
		MoveData.Move.WAIT:
			pass
		MoveData.Move.ATTACK:
			attack()
		MoveData.Move.VULNERABLE:
			vulnerable()
		MoveData.Move.FORETELL:
			foretell_random_move()
			
			
func foretell_random_move() -> void:
	var roll := randf()
	var move: MoveData.Move
	if roll <= 0.5:
		move = MoveData.Move.ATTACK
	elif roll <= 0.8:
		move = MoveData.Move.WAIT
	elif roll <= 1:
		move = MoveData.Move.VULNERABLE
	sprite.texture = get_sprite_for_move(move)
	saved_foretell.push_back(move)

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
	SignalHub.player_health_changed.emit(-damage)
	SignalHub.player_fail_attack.emit()
		
func take_damage() -> void:
	get_hit_sound.play()
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
