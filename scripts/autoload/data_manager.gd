# Autoload data yang dipakek di initial

extends Node

signal xp_changed(current_xp: int, next_level_xp: int)
signal level_up(current_level: int)

var move_speed: float = 300.0
var attack_damage: float = 10.0
var fire_rate: float = 0.2
var extra_fragments: int = 0

var current_xp: int = 0
var current_level: int = 1
var xp_to_next_level: int = 10

func add_xp(amount: int) -> void:
	current_xp += amount
	if current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		current_level += 1
		xp_to_next_level = int(xp_to_next_level * 1.5)
		level_up.emit(current_level)
	xp_changed.emit(current_xp, xp_to_next_level)