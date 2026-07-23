extends Control

@onready var health_bar: HealthBar = $"Health Bar"
@export var max_health: float = 150
@export var damage: float = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.setup_health(max_health)
	SignalHub.player_health_changed.connect(health_bar.update_health)
	SignalHub.enemy_attack.connect(on_enemy_attack)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		SignalHub.player_attack.emit(damage)
	
	if event.is_action_pressed("block"):
		block()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	health_bar.update_health(-delta)

var last_blocked_time: float = -1
var block_timer: SceneTreeTimer
var last_attack_time: float = -1

func on_enemy_attack(hit_damage: float) -> void:
	var current_time: float = Time.get_ticks_msec()
	last_attack_time = current_time
	if (current_time - last_blocked_time) < 100:
		block_timer.timeout.disconnect(fail_block)
		block_timer = null
		return
	health_bar.update_health(-hit_damage)

func block() -> void:
	if block_timer:
		fail_block()
	last_blocked_time = Time.get_ticks_msec()
	block_timer = get_tree().create_timer(0.1)
	block_timer.timeout.connect(fail_block)

func fail_block() -> void:
	var current_time: float = Time.get_ticks_msec()
	if (current_time - last_attack_time) > 150:
		health_bar.update_health(-damage)
	block_timer.timeout.disconnect(fail_block)
	block_timer = null
