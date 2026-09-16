class_name Asteroid
extends Area2D

enum Size { LARGE, MEDIUM, SMALL }
@export var size: Size = Size.LARGE
@export var base_speed: float = 50.0

@export var small_asteroid_scene: PackedScene
@export var alien_base_scene: PackedScene = preload("res://scenes/entities/aliens/alien_base.tscn")
@export var xp_orb_scene: PackedScene = preload("res://scenes/entities/xporb/xporb.tscn")
@export var skitter_script: Script = preload("res://scripts/entities/aliens/skitter.gd")

# Ledakan asteroid akalu ditembak
@export var explosion_damage: float = 2.0
@export var explosion_radius: float = 80.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Setting arah ama rotasi
	direction = Vector2.RIGHT.rotated(randf() * TAU)
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	# Posisi arahnya
	position += direction * base_speed * delta

func destroy() -> void:
	_explode_aoe_damage()

	if xp_orb_scene:
		var orb = xp_orb_scene.instantiate()
		orb.global_position = global_position
		get_parent().call_deferred("add_child", orb)

	if size != Size.SMALL and small_asteroid_scene:
		var extra = DataManager.extra_fragments if "extra_fragments" in DataManager else 0
		for i in range(2 + extra):
			var sub_ast = small_asteroid_scene.instantiate() as Asteroid
			sub_ast.global_position = global_position
			sub_ast.size = Size.SMALL if size == Size.MEDIUM else Size.MEDIUM
			get_parent().call_deferred("add_child", sub_ast)

	_try_spawn_alien()
	queue_free()

func _explode_aoe_damage() -> void:
	var query = PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = explosion_radius
	
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
