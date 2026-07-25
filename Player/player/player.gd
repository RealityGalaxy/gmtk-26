extends Control

@onready var health_bar: HealthBar = $"Health Bar"
var max_health: float = 150
var timing_window_ms: float = 100
var damage: float = 6

var game_paused := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerData.calc_player_traits()
	damage = PlayerData.base_damage * PlayerData.damage_dealt_mult
	timing_window_ms = PlayerData.base_block_window * PlayerData.block_window_mult
	max_health = PlayerData.base_max_health * PlayerData.time_mult
	health_bar.setup_health(max_health)
	SignalHub.player_health_changed.connect(health_bar.update_health)
	SignalHub.enemy_attack.connect(on_enemy_attack)
	SignalHub.game_pause.connect(func() -> void: game_paused=true)

func _input(event: InputEvent) -> void:	
	if game_paused:
		return
		
	if event.is_action_pressed("attack"):
		SignalHub.player_input.emit()
		SignalHub.player_attack.emit(damage * PlayerData.combo_multiplier)
	
	if event.is_action_pressed("block"):
		SignalHub.player_input.emit()
		block()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !game_paused:
		health_bar.update_health(-delta)
	
	if health_bar.target_value <= 0.0:
		SignalHub.player_died.emit()

var last_blocked_time: float = -1
var block_timer: SceneTreeTimer
var last_attack_time: float = -1
var last_attack_dmg: float = -1

func handle_block() -> void:
	SignalHub.player_success_block.emit()
	print_debug("player success block")
	if block_timer:
		block_timer.timeout.disconnect(fail_block)
		block_timer = null
	if PlayerData.block_pen > 0:
		health_bar.update_health(-last_attack_dmg * PlayerData.block_pen)
	if PlayerData.parry_damage > 0:
		SignalHub.player_parry.emit(damage * PlayerData.parry_damage)
	

func on_enemy_attack(hit_damage: float) -> void:
	var current_time: float = Time.get_ticks_msec()
	last_attack_time = current_time
	last_attack_dmg = hit_damage
	if (current_time - last_blocked_time) < timing_window_ms:
		handle_block()
		return
	get_tree().create_timer(timing_window_ms/1000.0).timeout.connect(take_hit)
	
func take_hit() -> void:
	var current_time: float = Time.get_ticks_msec()
	if (current_time - last_blocked_time) < timing_window_ms:
		handle_block()
		return
	SignalHub.enemy_hit_damage.emit()
	print_debug("player tanked a hit")
	health_bar.update_health(-last_attack_dmg * PlayerData.damage_taken_mult)

func block() -> void:
	if block_timer:
		fail_block()
		return
	last_blocked_time = Time.get_ticks_msec()
	block_timer = get_tree().create_timer(timing_window_ms/1000.0)
	block_timer.timeout.connect(fail_block)

func fail_block() -> void:
	var current_time: float = Time.get_ticks_msec()
	SignalHub.player_fail_attack.emit()
	print_debug("player block miss")
	if (current_time - last_attack_time) > timing_window_ms + 50.0:
		health_bar.update_health(-damage * PlayerData.block_fail_mult)
	block_timer.timeout.disconnect(fail_block)
	block_timer = null
