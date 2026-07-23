extends Node

# --- Player Signals ---
signal player_health_changed(delta: float)
signal player_attack(damage: float)


# --- Gameplay Signals ---
signal game_tick()


# --- Enemy Signals ---
signal enemy_attack(damage: float)
