class_name Asteroid
extends Area2D

enum Size { LARGE, MEDIUM, SMALL }
@export var size: Size = Size.LARGE:
	set(value):
		size = value
		if is_inside_tree():
			_update_size_properties()

@export var base_speed: float = 50.0

@export var small_asteroid_scene: PackedScene
@export var alien_base_scene: PackedScene = preload("res://scenes/entities/aliens/alien_base.tscn")
@export var xp_orb_scene: PackedScene = preload("res://scenes/entities/xporb/xporb.tscn")
@export var hp_orb_scene: PackedScene = preload("res://scenes/entities/hporb/hporb.tscn")
@export var skitter_script: Script = preload("res://scripts/entities/aliens/skitter.gd")
@export var explosion: AudioStream = preload("res://assets/sounds/sfx/ring_swift.wav")

# Ledakan asteroid kalau ditembak
@export var explosion_damage: float = 2.0
@export var explosion_radius: float = 80.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Setting arah dan rotasi
	direction = Vector2.RIGHT.rotated(randf() * TAU)
	rotation = direction.angle()
	
	_update_size_properties()

func _update_size_properties() -> void:
	var scale_factor: float = 1.0
	
	match size:
		Size.LARGE:
			scale_factor = 1.0
			base_speed = 40.0
		Size.MEDIUM:
			scale_factor = 0.65
			base_speed = 70.0
		Size.SMALL:
			scale_factor = 0.35
			base_speed = 100.0

	scale = Vector2(scale_factor, scale_factor)

func _physics_process(delta: float) -> void:
	# Posisi arahnya
	position += direction * base_speed * delta

func destroy() -> void:
	_explode_aoe_damage()

	var shake_power: float = 12.0
	var particle_count: int = 35
	var particle_scale: float = 2.2
	
	if size == Size.MEDIUM:
		shake_power = 7.0
		particle_count = 20
		particle_scale = 1.4
	elif size == Size.SMALL:
		shake_power = 3.0
		particle_count = 10
		particle_scale = 0.8

	if JuiceManager:
		JuiceManager.shake_camera(shake_power, 0.2)
		if size == Size.LARGE:
			JuiceManager.zoom_punch(0.08, 0.15)
	
	AudioManager.play_sfx(explosion)
	_spawn_burst(particle_count, Color.ORANGE, particle_scale)

	if xp_orb_scene:
		var orb = xp_orb_scene.instantiate()
		orb.global_position = global_position
		get_parent().call_deferred("add_child", orb)

	if size != Size.SMALL and small_asteroid_scene:
		var extra = DataManager.extra_fragments if "extra_fragments" in DataManager else 0
		for i in range(2 + extra):
			var sub_ast = small_asteroid_scene.instantiate() as Asteroid
			sub_ast.size = Size.SMALL if size == Size.MEDIUM else Size.MEDIUM
			sub_ast.global_position = global_position
			get_parent().call_deferred("add_child", sub_ast)

	_try_spawn_alien()
	_try_spawn_hp()
	queue_free()

func _spawn_burst(amount: int, color: Color, scale_factor: float) -> void:
	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = amount
	particles.color = color
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	
	particles.initial_velocity_min = 100.0 * scale_factor
	particles.initial_velocity_max = 200.0 * scale_factor
	particles.scale_amount_min = 2.0 * scale_factor
	particles.scale_amount_max = 5.0 * scale_factor
	
	particles.global_position = global_position
	get_parent().add_child(particles)
	
	particles.emitting = true
	get_tree().create_timer(particles.lifetime).timeout.connect(particles.queue_free)
	
func _explode_aoe_damage() -> void:
	var current_radius = explosion_radius * scale.x
	var query = PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = current_radius
	
	query.shape = circle_shape
	query.transform = Transform2D(0, global_position)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var space_state = get_world_2d().direct_space_state
	var results = space_state.intersect_shape(query)

	for res in results:
		var collider = res.collider
		if collider == self: continue
		
		if collider.is_in_group("Player"):
			collider.take_damage(explosion_damage)
		elif collider.owner and collider.owner.is_in_group("Player"):
			collider.owner.take_damage(explosion_damage)
		elif collider is AlienBase:
			collider.take_damage(explosion_damage)
		elif collider.owner and collider.owner is AlienBase:
			collider.owner.take_damage(explosion_damage)

func _try_spawn_alien() -> void:
	var wave_mgr = get_tree().get_first_node_in_group("WaveManager")
	if not wave_mgr or not wave_mgr.current_config: return
	
	var config = wave_mgr.current_config
	if randf() <= config.spawn_alien_chance and config.allowed_aliens.size() > 0:
		var chosen_data: AlienData = config.allowed_aliens.pick_random()
		
		if alien_base_scene:
			var alien = alien_base_scene.instantiate()
			if skitter_script:
				alien.set_script(skitter_script)
			alien.data = chosen_data
			alien.global_position = global_position
			get_parent().call_deferred("add_child", alien)

func _try_spawn_hp() -> void:
	if randf() <= 0.8:
		if hp_orb_scene:
			var hp_orb = hp_orb_scene.instantiate()
			hp_orb.global_position = global_position
			get_parent().call_deferred("add_child", hp_orb)