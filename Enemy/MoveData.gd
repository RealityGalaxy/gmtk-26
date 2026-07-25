class_name MoveData
extends Resource

enum Move {
	WAIT,
	ATTACK,
	VULNERABLE,
	FORETELL,
	EXECUTE,
}

@export var move: Move = Move.WAIT
@export var foretell_order: int = -1
@export var sprite_on_tick: bool = true
@export var sprite_flipped_h: bool = false
@export var move_text: String = ""
