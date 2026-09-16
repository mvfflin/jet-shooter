class_name Player
extends CharacterBody2D

# Config & Stats
const SPEED = 300.0
const ROTATION_SPEED = 15.0
var hp: float = 5.0

# Fire Properties
var fire_rate: float = 0.5
var time_since_last_shot: float = 0.0
var can_shoot: bool = true

# Preload bullet
@export var bullet_scene: PackedScene = preload("res://scenes/entities/bullet/bullet.tscn")

func _ready() -> void:
	add_to_group("Player")

func _physics_process(delta: float) -> void:
	# Player Movement
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	move_and_slide()

	# Mouse Aim
	var mouse_pos = get_global_mouse_position()
	var aim_dir = (mouse_pos - global_position).normalized()
	
	if aim_dir != Vector2.ZERO:
		rotation = lerp_angle(rotation, aim_dir.angle(), ROTATION_SPEED * delta)
	
	# Auto Fire Logic
	if can_shoot:
		time_since_last_shot += delta
		if time_since_last_shot >= fire_rate:
			_shoot_projectile(aim_dir)
			time_since_last_shot = 0.0

func _shoot_projectile(aim_dir: Vector2) -> void:
	if not bullet_scene: return
	
	var projectile = bullet_scene.instantiate()
	
	# Ambil data damage/stat langsung dari DataManager jika sudah ada
	if DataManager:
		projectile.damage = DataManager.attack_damage
	
	# Setting posisi muzzle dan peluru keluar
	projectile.global_position = $Marker2D.global_position
	projectile.set_direction(aim_dir)

	# Set agar peluru tau siapa yang nembak (Player)
	projectile.set_shooter(self)

	get_parent().add_child(projectile)

func take_damage(amount: float) -> void:
	hp -= amount
	print("DEBUGLOG Player: Terkena damage ", amount, " | Sisa HP: ", hp)
	
	if hp <= 0:
		print("DEBUGLOG Player: HP habis (0)! Player hancur (queue_free).")
		queue_free()