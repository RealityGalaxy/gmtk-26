extends Node

# --- Player Signals ---
signal player_health_changed(delta: float)
signal player_attack(damage: float)
signal player_parry(damage: float)


# --- Gameplay Signals ---
signal game_tick()
signal combo_reset()
signal combo_stack()


# --- Enemy Signals ---
signal enemy_attack(damage: float)
