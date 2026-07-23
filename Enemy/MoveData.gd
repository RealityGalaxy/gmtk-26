class_name MoveData
extends Resource

enum Move {
	WAIT,
	ATTACK,
	VULNERABLE
}

@export var move_name: String = ""
@export var move_sequence: Array[Move] = []
