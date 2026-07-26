extends ColorRect

signal go_back_button()
signal retry_button()

@onready var game_over_content: Control = $"Game Over Content"
@onready var game_over_text: RichTextLabel = $"Game Over Content/Game Over Text"

func _ready() -> void:
	SignalHub.enemy_died.connect(game_end.bind("Won"))
	SignalHub.player_died.connect(game_end.bind("Lost"))

func game_end(state: String) -> void:
	game_over_text.text = get_game_over_text(state)
	if state == "Won" and !PlayerData.in_tutorial:
		PlayerData.fights_won[PlayerData.current_fight_num] = true
		PlayerData.fights_unlocked[min(PlayerData.current_fight_num+1, 2)] = true
	var color_to: Color = Color.from_rgba8(0,0,0,230)
	create_tween().tween_property(self, "color", color_to, 0.5).set_ease(Tween.EASE_IN_OUT)
	get_tree().create_timer(1).timeout.connect(allow_quick_retry)
	game_over_content.visible = true
	
var retry_flag := false
	
func allow_quick_retry() -> void:
	retry_flag = true

func _input(event: InputEvent) -> void:
	if !retry_flag:
		return
	if event.is_action_pressed("attack") or event.is_action_pressed("block"):
		SignalHub.restart_game.emit()
	
func get_game_over_text(state: String) -> String:
	var the_end := ""
	if state == "Won":
		the_end = "Completed The Tutorial" if PlayerData.in_tutorial else "Won"
	else:
		the_end = "Ran Out Of Time"
	return "You " + the_end

func _on_button_pressed() -> void:
	go_back_button.emit()


func _on_retry_pressed() -> void:
	retry_button.emit()
