class_name BulletBase
extends Area2D

@export var speed: float = 600.0
@export var damage: float = 1.0
@export var lifetime: float = 3.0
@export var is_player_bullet: bool = true 

var direction: Vector2 = Vector2.RIGHT
var shooter: Node2D = null
var timer: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	call_deferred("_setup_bullet_color_and_trail")

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	timer += delta
	if timer >= lifetime:
		queue_free()

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func set_shooter(node: Node2D) -> void:
	shooter = node

	if node is AlienBase:
		is_player_bullet = false
	
	_setup_bullet_color_and_trail()

func _setup_bullet_color_and_trail() -> void:
	var sprite = get_node_or_null("Sprite2D") as Sprite2D
	var bullet_color = Color.RED 

	if is_instance_valid(shooter):
		if shooter.is_in_group("Alien"):
			bullet_color = Color.LIME_GREEN 
		elif shooter.is_in_group("Player"):
			bullet_color = Color.RED 

	if sprite:
		sprite.modulate = bullet_color

	_attach_trail(bullet_color)

func _on_body_entered(body: Node2D) -> void:
	if body == shooter: return
	
	if not is_player_bullet and body.is_in_group("Player"):
		_on_hit_target(body)
	elif is_player_bullet:
		if body is AlienBase or body is BossEnemy or body.is_in_group("Alien") or body.is_in_group("Boss"):
			_on_hit_target(body)

func _on_area_entered(area: Area2D) -> void:
	if area == shooter or (area.owner and area.owner == shooter): return
	
	if is_player_bullet:
		var target = area.get_parent() if area.get_parent() else area.owner
		
		if target and (target is AlienBase or target is BossEnemy or target is BossBullet or target.is_in_group("Boss") or target.is_in_group("Alien")):
			_on_hit_target(target)
			return
			
		if area.has_method("destroy"):
			area.destroy()
			queue_free()
			return

	else:
		var target = area.get_parent() if area.get_parent() else area.owner
		if target and target.is_in_group("Player"):
			_on_hit_target(target)

func _on_hit_target(target: Node2D) -> void:
	if target.has_method("take_damage"):
		target.take_damage(damage)
	elif target is Asteroid and target.has_method("destroy"):
		target.destroy()
		
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

func _on_timer_timeout() -> void:
	queue_free()
