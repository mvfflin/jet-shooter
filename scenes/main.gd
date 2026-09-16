## main.gd — entry point untuk level. Setup viewport + kamera, spawn player,
## dan trigger WaveManager.

extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var player: Node2D = $Player
@onready var ysort: Node2D = $YSort

func _ready() -> void:
	# Kamera fixed di layar — fixed top-left anchor (player bergerak, kamera nggak ikut)
	camera.make_current()
	camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT

	var viewport_size := get_viewport_rect().size
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = viewport_size.x
	camera.limit_bottom = viewport_size.y

	# Spawn player di tengah
	player.global_position = viewport_size / 2.0

func _physics_process(_delta: float) -> void:
	if not player:
		return

	# Clamp posisi player dalam viewport
	var viewport_size := get_viewport_rect().size
	var margin := 40.0
	var min_pos := Vector2(margin, margin)
	var max_pos := viewport_size - Vector2(margin, margin)

	var pos := player.global_position
	pos.x = clamp(pos.x, min_pos.x, max_pos.x)
	pos.y = clamp(pos.y, min_pos.y, max_pos.y)
	player.global_position = pos
