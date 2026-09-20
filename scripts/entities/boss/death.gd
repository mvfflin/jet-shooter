extends State

@export var explosion_sfx: AudioStream = preload("res://assets/sounds/sfx/explosion.wav")

func enter() -> void:
	super.enter()
	
	_clear_all_minions_and_asteroids()
	
	if animation_player and animation_player.has_animation("Death"):
		animation_player.play("Death")
	
	await _play_flamboyant_explosions()
	
	await _play_white_flash()
	
	if owner and owner.has_method("_on_boss_slain_complete"):
		owner._on_boss_slain_complete()
	else:
		SceneTransition.change_scene("res://scenes/ui/winning_credit.tscn", 1.0)


func _clear_all_minions_and_asteroids() -> void:
	var minions = get_tree().get_nodes_in_group("Alien")
	for minion in minions:
		if is_instance_valid(minion) and minion != owner:
			minion.queue_free()
			
	var asteroids = get_tree().get_nodes_in_group("Asteroid")
	for asteroid in asteroids:
		if is_instance_valid(asteroid):
			asteroid.queue_free()


func _play_flamboyant_explosions() -> void:
	var main_scene = owner.get_parent()
	var colors: Array[Color] = [
		Color(1.0, 0.2, 0.2), 
		Color(0.2, 0.8, 1.0), 
		Color(1.0, 0.85, 0.0) 
	]
	
	for i in range(3):
		var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
		var explosion_pos = owner.global_position + offset
		
		_spawn_colorful_particles(main_scene, explosion_pos, colors[i])
		AudioManager.play_sfx(explosion_sfx)
		
		if JuiceManager:
			JuiceManager.shake_camera(15.0 + (i * 10.0), 0.5)
			
		await get_tree().create_timer(0.4).timeout


func _spawn_colorful_particles(parent_node: Node, pos: Vector2, color: Color) -> void:
	var particles = GPUParticles2D.new()
	var mat = ParticleProcessMaterial.new()
	
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 20.0
	mat.direction = Vector3.ZERO
	mat.spread = 180.0
	mat.initial_velocity_min = 200.0
	mat.initial_velocity_max = 500.0
	mat.gravity = Vector3.ZERO
	mat.scale_min = 4.0
	mat.scale_max = 8.0
	mat.color = color
	
	particles.process_material = mat
	particles.amount = 80
	particles.lifetime = 0.6
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.global_position = pos
	
	parent_node.add_child(particles)
	particles.emitting = true
	
	get_tree().create_timer(1.0).timeout.connect(particles.queue_free)


func _play_white_flash() -> void:
	var flash_overlay = ColorRect.new()
	flash_overlay.color = Color(1.0, 1.0, 1.0, 0.0)
	flash_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var main_scene = owner.get_parent()
	var canvas_layer = main_scene.get_node_or_null("CanvasLayer")
	
	if canvas_layer:
		canvas_layer.add_child(flash_overlay)
	else:
		main_scene.add_child(flash_overlay)
		
	var tween = create_tween()
	tween.tween_property(flash_overlay, "color:a", 1.0, 0.3) 
	tween.tween_interval(0.2)                                 
	await tween.finished