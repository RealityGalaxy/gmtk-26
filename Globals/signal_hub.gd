extends Node

# --- Player Signals ---
signal player_health_changed(delta: float)
signal player_attack(damage: float)
signal player_parry(damage: float)
signal player_fail_attack()
signal player_success_block()
signal player_died()
signal player_input()


# --- Gameplay Signals ---
signal game_tick()
signal animation_tick_start()
signal animation_tick_end()
signal combo_reset()
signal combo_stack()
signal game_pause()

# --- Enemy Signals ---
signal enemy_attack(damage: float)
signal enemy_hit_damage()
signal enemy_died()
signal enemy_bpm(bpm: float)
