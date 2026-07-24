extends Timer

@onready var ticker: AudioStreamPlayer  = $Ticker

var animation_tick_started: bool = false
var animation_tick_ended: bool = false

func _process(_delta: float) -> void:
	if time_left <= 0.1:
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
