extends AlienBase

@export var shoot_interval: float = 2.5
@export var bullet_scene: PackedScene = preload("res://scenes/entities/bullet/bullet.tscn")
@export var shoot_sfx: AudioStream = preload("res://assets/sounds/sfx/enemy_shoot.wav")

var shoot_timer: float = 0.0

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player): return
	
	# Drift pelan ke arah player
	var dir = (player.global_position - global_position).normalized()
	rotation = dir.angle()
	velocity = dir * (data.speed * 0.3 if data else 30.0)
	move_and_slide()
	
	# Logic shoot
	shoot_timer += delta
	if shoot_timer >= shoot_interval:
		shoot_timer = 0.0
		_shoot()

func _shoot() -> void:
	if not bullet_scene or not is_instance_valid(player): return
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	if bullet.has_method("set_shooter"):
		bullet.set_shooter(self)
	var dir = (player.global_position - global_position).normalized()
	if bullet.has_method("set_direction"):
		bullet.set_direction(dir)
	AudioManager.play_sfx(shoot_sfx)
	get_parent().add_child(bullet)