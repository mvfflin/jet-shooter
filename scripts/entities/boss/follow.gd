extends State

func enter() -> void:
	super.enter()
	if owner.has_node("AnimationPlayer"):
		owner.find_child("AnimationPlayer").play("Idle")
		
func transition() -> void:
	if not is_instance_valid(player): return
	
	var distance = owner.direction.length()
	
	if distance < 100.0:
		get_parent().change_state("MeleeAttack")
	elif distance > 150.0:
		var change = randi() % 2
		match change:
			0:
				get_parent().change_state("HomingMissile")
			1:
				get_parent().change_state("LaserBeam")