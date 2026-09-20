extends AlienBase

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player): return

	var dir = (player.global_position - global_position).normalized()
	velocity = dir * (data.speed if data else 50.0)
	rotation = dir.angle()
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(data.damage if data else 1.0)
		
		# Fungsi sedot xp
		if DataManager and DataManager.current_xp > 0:
			DataManager.current_xp = max(0, DataManager.current_xp - 10)
		queue_free()