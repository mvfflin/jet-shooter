class_name BossBullet
extends Area2D

@export var damage: float = 1.0
@export var max_health: float = 2.0

var player: Node2D = null
var velocity: Vector2 = Vector2.ZERO
var acceleration: Vector2 = Vector2.ZERO
var current_health: float = 2.0

func _ready() -> void:
	add_to_group("Alien") 
	current_health = max_health
	player = get_tree().get_first_node_in_group("Player")
	_attach_trail(Color(0.1, 0.6, 1.0, 1.0))

func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		acceleration = (player.global_position - global_position).normalized() * 600.0
		velocity += acceleration * delta
		rotation = velocity.angle()
		
		velocity = velocity.limit_length(180.0)
		global_position += velocity * delta
	else:
		global_position += velocity * delta

func take_damage(amount: float) -> void:
	current_health -= amount
	
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.modulate = Color.RED
		create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.1)

	if current_health <= 0:
		_destroy()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(damage)
		_destroy()

func _destroy() -> void:
	if JuiceManager:
		JuiceManager.shake_camera(2.0, 0.05)
	
	_spawn_burst(10, Color(0.1, 0.6, 1.0, 1.0), 1.0)
	
	queue_free()

func _attach_trail(trail_color: Color) -> void:
	var old_trail = get_node_or_null("MotionTrail")
	if old_trail:
		old_trail.queue_free()

	var trail_scene = preload("res://scenes/effects/motion_trail.tscn")
	if trail_scene:
		var trail = trail_scene.instantiate() as MotionTrail
		trail.name = "MotionTrail"
		add_child(trail)
		trail.set_trail_color(trail_color)

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