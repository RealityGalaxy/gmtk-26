extends Timer

@onready var ticker: AudioStreamPlayer  = $Ticker

var animation_tick_started: bool = false
var animation_tick_ended: bool = false

func _ready() -> void:
	SignalHub.player_input.connect(_on_input)

func _process(_delta: float) -> void:
	if time_left <= 0.05:
		SignalHub.animation_tick_start.emit()
		animation_tick_started = true
	if time_left <= 0.35:
		SignalHub.animation_tick_end.emit()
		animation_tick_ended = true

func _on_timeout() -> void:
	SignalHub.game_tick.emit()
	ticker.play()
	animation_tick_started = false
	animation_tick_ended = false

func _on_input() -> void:
	print_debug("+"+str(snapped((wait_time - time_left)*1000, 0.1)) if time_left > wait_time/2 else "-"+str(snapped(time_left*1000, 0.1)))
