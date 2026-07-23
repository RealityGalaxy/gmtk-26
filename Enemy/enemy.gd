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
@onready var sprite: TextureRect = $"Enemy Image"
@onready var temp_text: RichTextLabel = $"Enemy Image/RichTextLabel"
@export var timing_window_ms: float = 100
@export var damage: float = 6
@export var max_health: float = 150
@export var move_set: Array[MoveData] = []
@export var next_move_in: int = 5

var current_state: EnemyState = EnemyState.DEFAULT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.setup_health(max_health)
	SignalHub.game_tick.connect(on_tick)
	SignalHub.player_attack.connect(on_player_attack)
	SignalHub.player_parry.connect(on_player_parry)
	temp_text.text = ""
	
func on_player_parry(damage: float) -> void:
	health_bar.update_health(-damage)

func on_tick() -> void:
	next_move_in -= 1
	if next_move_in == 0:
		execute_random_move()

func execute_random_move() -> void:
	var moves: MoveData = move_set.pick_random()
	temp_text.text = moves.move_name
	for move in moves.move_sequence:
		await do_move(move)
		temp_text.text = ""
	next_move_in = randi_range(3, 6)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	health_bar.update_health(-delta)

func do_move(move: MoveData.Move) -> void:
	await SignalHub.game_tick
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
	SignalHub.player_health_changed.emit(-damage)
		
func take_damage() -> void:
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
		FlashState.ATTACK:
			return Color.RED
		FlashState.BLOCK:
			return Color.ROYAL_BLUE
		FlashState.DAMAGED:
			return Color.DARK_RED
		FlashState.VULNERABLE:
			return Color.YELLOW
		_:
			return Color.WHITE
