class_name MoveData
extends Resource

enum Move {
	WAIT,
	ATTACK,
	VULNERABLE
}

@export var move: Move = Move.WAIT
@export var sprite_on_tick: bool = true
@export var sprite_flipped_h: bool = false
