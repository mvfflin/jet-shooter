class_name AlienBase
extends CharacterBody2D

@export var data: AlienData
@export var xp_orb_scene: PackedScene = preload("res://scenes/entities/xporb/xporb.tscn")
@export var hp_orb_scene: PackedScene = preload("res://scenes/entities/hporb/hporb.tscn")
@export var take_damage_sfx: AudioStream = preload("res://assets/sounds/sfx/take_damage.wav")

var current_hp: float = 1.0
var player: Node2D
var base_scale: Vector2 = Vector2.ONE 
var current_speed: float = 100.0
var is_slowed: bool = false
var slow_timer: SceneTreeTimer

@onready var sprite: Sprite2D = $Sprite2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox_area: Area2D = $HitboxArea
@onready var hitbox_collision: CollisionShape2D = $HitboxArea/CollisionShape2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	setup_visual()

func setup_visual() -> void:
	if not sprite:
		sprite = get_node_or_null("Sprite2D") as Sprite2D
		
	if data and sprite:
		current_hp = data.max_hp
		current_speed = data.speed
		# Setup visual
		if data.texture:
			sprite.texture = data.texture
			
			var target_size = data.sprite_size if "sprite_size" in data and data.sprite_size > 0 else 32.0
			var tex_size = data.texture.get_size()
			if tex_size.x > 0 and tex_size.y > 0:
				var max_dim = max(tex_size.x, tex_size.y)
				var scale_factor = target_size / max_dim
				
				base_scale = Vector2(scale_factor, scale_factor)
				sprite.scale = base_scale
				print("DEBUGLOG Alien Visual: Scaled ", data.name, " dengan faktor ", scale_factor)
		
		sprite.modulate = data.color if data.color != Color(0, 0, 0, 0) else Color.MAGENTA
		
		# Setup physic
		var radius_size = data.hitbox_radius if "hitbox_radius" in data and data.hitbox_radius > 0 else 11.0
		_update_collisions(radius_size)

func _update_collisions(radius_size: float) -> void:
	if body_collision:
		var body_shape = CircleShape2D.new()
		body_shape.radius = radius_size * 0.85
		body_collision.shape = body_shape
		
	if hitbox_collision:
		var hitbox_shape = CircleShape2D.new()
		hitbox_shape.radius = radius_size
		hitbox_collision.shape = hitbox_shape

func take_damage(amount: float) -> void:
	if current_hp <= 0: return
	
	current_hp -= amount
	_play_hit_feedback()

	AudioManager.play_sfx(take_damage_sfx)
	
	print("DEBUGLOG Alien: Menerima damage ", amount, " | Sisa HP: ", current_hp)
	if current_hp <= 0:
		die()

func _play_hit_feedback() -> void:
	# Hit-stop
	if JuiceManager:
		JuiceManager.hit_stop(0.04)
		JuiceManager.shake_camera(3.0, 0.1)

	var sp = get_node_or_null("Sprite2D") as Sprite2D
	if not sp: return

	# Squash & stretch
	var tween = create_tween().set_parallel(true)
	sp.modulate = Color(3.0, 3.0, 3.0, 1.0) 
	
	sp.scale = Vector2(base_scale.x * 1.3, base_scale.y * 0.7)
	
	tween.tween_property(sp, "modulate", data.color if data else Color.WHITE, 0.12)
	
	# Back to scale
	tween.tween_property(sp, "scale", base_scale, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _spawn_burst(amount: int, p_color: Color, scale_factor: float) -> void:
	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = amount
	particles.color = p_color
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

func die() -> void:
	var shake_intensity = data.death_shake_intensity if data else 4.0
	var shake_duration = data.death_shake_duration if data else 0.1
	var zoom_punch = data.death_zoom_punch if data else 0.0
	var p_count = data.death_particle_count if data else 12
	var p_color = data.death_particle_color if data else Color.LIME_GREEN
	var p_scale = data.death_particle_scale if data else 1.0

	if JuiceManager:
		JuiceManager.shake_camera(shake_intensity, shake_duration)
		if zoom_punch > 0.0:
			JuiceManager.zoom_punch(zoom_punch, 0.12)
	
	_spawn_burst(p_count, p_color, p_scale)

	print("DEBUGLOG Alien: Alien mati di posisi ", global_position)
	_spawn_xp_orb()
	_try_spawn_hp()
	queue_free()

func _spawn_xp_orb() -> void:
	if xp_orb_scene:
		var orb = xp_orb_scene.instantiate()
		orb.global_position = global_position
		if "xp_amount" in orb and data:
			orb.xp_amount = data.xp_value
			
		get_parent().call_deferred("add_child", orb)

func _try_spawn_hp() -> void:
	if randf() <= 0.03:
		if hp_orb_scene:
			var hp_orb = hp_orb_scene.instantiate()
			hp_orb.global_position = global_position
			get_parent().call_deferred("add_child", hp_orb)

func apply_slow(slow_factor: float, duration: float) -> void:
	if not data: return

	current_speed = data.speed * slow_factor
	
	# Visual froze
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color.CYAN
	else:
		modulate = Color.CYAN

	is_slowed = true
	
	var tree = get_tree()
	if tree:
		await tree.create_timer(duration).timeout
		
		if is_instance_valid(self) and data:
			current_speed = data.speed
			is_slowed = false
			
			if sprite:
				sprite.modulate = Color.WHITE
			else:
				modulate = data.color if data.color != Color(0,0,0,0) else Color.WHITE
			print("DEBUGLOG AlienBase: Efek slow habis pada ", data.name)
