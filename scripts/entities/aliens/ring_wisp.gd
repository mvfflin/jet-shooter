extends AlienBase

@export var orbit_radius: float = 180.0
@export var orbit_speed: float = 2.0
@export var shoot_cooldown: float = 1.0 
@export var bullet_scene: PackedScene = preload("res://scenes/entities/bullet/bullet.tscn")
@export var shoot_sfx: AudioStream = preload("res://assets/sounds/sfx/enemy_shoot.wav")
@export var ring_swift: AudioStream = preload("res://assets/sounds/sfx/ring_swift.wav")

# Cek sejajar minimal
@export var alignment_threshold: float = 0.95 

var current_angle: float = 0.0
var cooldown_timer: float = 0.0

func _ready() -> void:
	super._ready()
	current_angle = randf() * TAU
	AudioManager.play_sfx(ring_swift)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player): return
	
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	
	# Logic orbit
	current_angle += orbit_speed * delta
	var target_pos = player.global_position + Vector2(cos(current_angle), sin(current_angle)) * orbit_radius
	global_position = global_position.lerp(target_pos, 5.0 * delta)

	var dir_to_player = (player.global_position - global_position).normalized()
	rotation = dir_to_player.angle()

	# Logic tembakan sejajar player
	if cooldown_timer <= 0.0:
		_check_and_shoot(dir_to_player)

func _check_and_shoot(dir_to_player: Vector2) -> void:
	# Ambil arah gerak/vektor player
	var player_dir = Vector2.ZERO
	if "velocity" in player and player.velocity.length() > 10.0:
		player_dir = player.velocity.normalized()
	else:
		# Jika player diam, gunakan arah hadap player (vektor rotasi)
		player_dir = Vector2.RIGHT.rotated(player.rotation)

	# Hitung Dot Product antara arah hadap alien ke player vs arah gerak player
	var alignment = abs(dir_to_player.dot(player_dir))

	# Jika alignment > 0.95 (hampir garis lurus sejajar), maka akan menembak
	if alignment >= alignment_threshold:
		_shoot(dir_to_player)
		cooldown_timer = shoot_cooldown

func _shoot(dir: Vector2) -> void:
	if not bullet_scene or not is_instance_valid(player): return
	
	print("DEBUGLOG RingWisp: Sejajar dengan Player! Menembak...")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	if bullet.has_method("set_shooter"):
		bullet.set_shooter(self)
	if bullet.has_method("set_direction"):
		bullet.set_direction(dir)
	
	AudioManager.play_sfx(shoot_sfx)
	get_parent().add_child(bullet)