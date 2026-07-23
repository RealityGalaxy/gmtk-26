extends Node

var player_traits: Array[TraitData] = []

func _ready() -> void:
	SignalHub.combo_reset.connect(on_combo_reset)
	SignalHub.combo_stack.connect(on_combo_stack)
	
func on_combo_stack() -> void:
	combo_multiplier += 0.1
	
func on_combo_reset() -> void:
	combo_multiplier = 1

# --- Base Stats ---
var base_max_health: float = 150
var base_damage: float = 6
var base_block_window: float = 100
# --- Base Stats ---

# --- Calculated Multipliers ---
var time_mult: float = 1 #
var block_window_mult: float = 1 #
var block_pen: float = 0 #
var block_fail_mult: float = 1 #
var parry_damage: float = 0 #
var time_steal: float = 0 #
var damage_dealt_mult: float = 1 #
var damage_taken_mult: float = 1 #
var attack_combo: bool = false

var combo_multiplier: float = 1
# --- Calculated Multipliers ---

func reset_player_traits() -> void:
	time_mult = 1
	block_window_mult = 1
	block_fail_mult = 1 
	block_pen = 0
	parry_damage = 0
	time_steal = 0
	damage_dealt_mult = 1
	damage_taken_mult = 1
	attack_combo = false

func calc_player_traits() -> void:
	reset_player_traits()
	for trait_data: TraitData in player_traits:
		time_mult *= trait_data.time_mult
		block_window_mult *= trait_data.block_window_mult
		block_fail_mult *= trait_data.block_fail_mult
		block_pen += trait_data.block_pen
		parry_damage += trait_data.parry_damage
		time_steal += trait_data.time_steal
		damage_dealt_mult *= trait_data.damage_dealt_mult
		damage_taken_mult *= trait_data.damage_taken_mult
		attack_combo = attack_combo || trait_data.attack_combo
