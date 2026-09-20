class_name MotionTrail
extends Line2D

@export var max_length: int = 10

func _ready() -> void:
	top_level = true
	global_position = Vector2.ZERO
	global_rotation = 0

func _process(_delta: float) -> void:
	var parent_node = get_parent() as Node2D
	if not is_instance_valid(parent_node):
		queue_free()
		return

	add_point(parent_node.global_position)
	
	if points.size() > max_length:
		remove_point(0)

# Fungsi untuk mengubah warna trail dari luar script
func set_trail_color(base_color: Color) -> void:
	var new_gradient = Gradient.new()
	new_gradient.set_color(0, base_color)
	new_gradient.set_color(1, Color(base_color.r, base_color.g, base_color.b, 0.0))
	gradient = new_gradient