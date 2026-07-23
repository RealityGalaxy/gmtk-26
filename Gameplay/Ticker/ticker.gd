extends Timer

@onready var ticker: AudioStreamPlayer  = $Ticker


func _on_timeout() -> void:
	SignalHub.game_tick.emit()
	ticker.play()
