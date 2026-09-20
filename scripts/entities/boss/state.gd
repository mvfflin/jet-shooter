extends Node2D
class_name State

@onready var debug = owner.find_child("debug")
@onready var animation_player = owner.find_child("AnimationPlayer")
var player: Node2D = null

func _ready() -> void:
	set_physics_process(false)

func enter() -> void:
	player = get_tree().get_first_node_in_group("Player")
	set_physics_process(true)

func exit() -> void:
	set_physics_process(false)

func transition() -> void:
	pass

func _physics_process(_delta: float) -> void:
	transition()
	if debug:
		debug.text = name