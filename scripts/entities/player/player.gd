class_name Player
extends CharacterBody2D

const ROTATION_SPEED = 15.0
var time_since_last_shot: float = 0.0
var can_shoot: bool = true
var is_dead: bool = false

@export var bullet_scene: PackedScene = preload("res://scenes/entities/bullet/bullet.tscn")
@export var laser_scene: PackedScene = preload("res://scenes/entities/bullet/laser_beam.tscn")
@export var game_over_scene: PackedScene = preload("res://scenes/ui/game_over_screen.tscn")
@export var glitch: AudioStream = preload("res://assets/sounds/sfx/glitch.wav")
@export var take_damage_sfx: AudioStream = preload("res://assets/sounds/sfx/take_damage.wav")
@export var shoot_sfx: AudioStream = preload("res://assets/sounds/sfx/shoot.wav")
@export var scan_samples: int = 12
@export var scan_radius: float = 200.0 

func _ready() -> void:
	add_to_group("Player")
	if DataManager:
		DataManager.hp_changed.emit(DataManager.current_hp, DataManager.max_hp)

func _process(delta: float) -> void:
	if is_dead: return

	# Regen energi pasif
	if DataManager and DataManager.current_energy < DataManager.max_energy:
		DataManager.add_energy(DataManager.passive_energy_rate * delta)
	
	# Input trigger hyperspace
	if Input.is_action_just_pressed("hyperspace"):
		_try_hyperspace_teleport()

func _physics_process(delta: float) -> void:
	if is_dead: return

	# Movement 
	var move_speed = DataManager.move_speed if DataManager else 300.0
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction * move_speed
	move_and_slide()

	# Mouse Aiming
	var mouse_pos = get_global_mouse_position()
	var aim_dir = (mouse_pos - global_position).normalized()
	
	if aim_dir != Vector2.ZERO:
		rotation = lerp_angle(rotation, aim_dir.angle(), ROTATION_SPEED * delta)
	
	# Auto Fire
	if can_shoot:
		var current_fire_rate = DataManager.fire_rate if DataManager else 0.5
		time_since_last_shot += delta
		if time_since_last_shot >= current_fire_rate:
			_shoot_projectile(aim_dir)
			time_since_last_shot = 0.0
	
	_clamp_to_screen()

func _clamp_to_screen() -> void:
	var viewport_rect := get_viewport_rect()
	var margin := 16.0 
	
	global_position.x = clamp(global_position.x, margin, viewport_rect.size.x - margin)
	global_position.y = clamp(global_position.y, margin, viewport_rect.size.y - margin)

func _try_hyperspace_teleport() -> void:
	if not DataManager or DataManager.current_energy < DataManager.max_energy:
		print("DEBUGLOG Player: Energy belum penuh!")
		return

	if DataManager.consume_hyperspace_energy():
		_execute_glitch_teleport()

func _execute_glitch_teleport() -> void:
	# Shutdown can_shoot biar gak bisa nembak
	can_shoot = false 
	print("DEBUGLOG Player: Hyperspace Activated! Memulai Glitch Teleport...")

	# SFX Glitch
	AudioManager.play_sfx(glitch)
	var sprite = get_node_or_null("Sprite2D")
	var target_pos = _find_safest_teleport_position()
	
	# Simpan ukuran asli sprite sebelum glitch
	var original_scale = sprite.scale if sprite else Vector2.ONE

	var glitch_tween = create_tween().set_loops(6)
	glitch_tween.tween_callback(func():
		if sprite:
			sprite.visible = not sprite.visible
			sprite.scale = Vector2(randf_range(0.6, 1.4), randf_range(0.6, 1.4))
			sprite.modulate = Color(randf(), randf(), 1.0) # Flash warna RGB/Cyan
			global_position += Vector2(randf_range(-15, 15), randf_range(-15, 15))
	)
	glitch_tween.tween_interval(0.03)

	# Eksekusi
	glitch_tween.finished.connect(func():
		# Pindahkan player ke lokasi paling aman
		global_position = target_pos
		
		# Reset Visual Sprite
		if sprite:
			sprite.visible = true
			sprite.scale = original_scale
			sprite.modulate = Color.WHITE
		
		can_shoot = true
		print("DEBUGLOG Player: Teleport Selesai ke Posisi Aman -> ", global_position)
	, CONNECT_ONE_SHOT)

func _find_safest_teleport_position() -> Vector2:
	var viewport_rect = get_viewport_rect()
	var margin = 60.0
	var best_pos = global_position
	var lowest_threat_score: float = 999999.0

	var enemies = get_tree().get_nodes_in_group("Alien")
	var asteroids = get_tree().get_nodes_in_group("Asteroid")
	var bosses = get_tree().get_nodes_in_group("Boss") 

	for i in range(scan_samples):
		var test_pos = Vector2(
			randf_range(margin, viewport_rect.size.x - margin),
			randf_range(margin, viewport_rect.size.y - margin)
		)

		var current_threat_score: float = 0.0

		for boss in bosses:
			if is_instance_valid(boss):
				var dist = test_pos.distance_to(boss.global_position)
				var boss_danger_zone = scan_radius * 1.5 
				if dist < boss_danger_zone:
					current_threat_score += (boss_danger_zone - dist) * 3.0

		for enemy in enemies:
			if is_instance_valid(enemy):
				var dist = test_pos.distance_to(enemy.global_position)
				if dist < scan_radius:
					current_threat_score += (scan_radius - dist)

		for asteroid in asteroids:
			if is_instance_valid(asteroid):
				var dist = test_pos.distance_to(asteroid.global_position)
				if dist < scan_radius:
					current_threat_score += (scan_radius - dist) * 0.5

		if current_threat_score < lowest_threat_score:
			lowest_threat_score = current_threat_score
			best_pos = test_pos

	return best_pos

func _shoot_projectile(aim_dir: Vector2) -> void:
	if not DataManager: return

	var traits = DataManager.active_weapon_traits
	var spawn_pos = global_position
	if has_node("Marker2D"):
		spawn_pos = $Marker2D.global_position
	
	AudioManager.play_sfx(shoot_sfx)

	if traits.has(UpgradeData.WeaponType.LASER):
		_spawn_laser_beam(spawn_pos, aim_dir, traits)

	_spawn_bullet_cluster(spawn_pos, aim_dir, traits)

func _spawn_laser_beam(spawn_pos: Vector2, aim_dir: Vector2, traits: Array[UpgradeData.WeaponType]) -> void:
	if not laser_scene: return

	var laser = laser_scene.instantiate()
	laser.damage = DataManager.attack_damage
	laser.global_position = spawn_pos
	laser.rotation = aim_dir.angle()
	
	if laser.has_method("set_shooter"):
		laser.set_shooter(self)

	if "traits" in laser:
		laser.traits = traits.duplicate()

	get_parent().add_child(laser)

func _spawn_bullet_cluster(spawn_pos: Vector2, aim_dir: Vector2, traits: Array[UpgradeData.WeaponType]) -> void:
	var has_spread = traits.has(UpgradeData.WeaponType.SPREAD)

	if has_spread:
		# Tembak 5 peluru menyebar 
		var spread_angles = [-0.52, -0.26, 0.0, 0.26, 0.52]
		for angle in spread_angles:
			var rotated_dir = aim_dir.rotated(angle)
			_spawn_single_modular_bullet(spawn_pos, rotated_dir, traits)
	else:
		# Tembak 1 peluru lurus
		_spawn_single_modular_bullet(spawn_pos, aim_dir, traits)

func _spawn_single_modular_bullet(spawn_pos: Vector2, dir: Vector2, traits: Array[UpgradeData.WeaponType]) -> void:
	if not bullet_scene: return

	var projectile = bullet_scene.instantiate() as BulletBase

	# Pasang script modular_bullet 
	projectile.set_script(preload("res://scripts/entities/bullet/modular_bullet.gd"))
	
	if DataManager:
		projectile.damage = DataManager.attack_damage

	# Oper array traits ke peluru modular
	if "traits" in projectile:
		projectile.traits = traits.duplicate()

	projectile.global_position = spawn_pos
	projectile.set_direction(dir)
	projectile.set_shooter(self)

	get_parent().add_child(projectile)

func take_damage(amount: float) -> void:
	if is_dead or not DataManager: return

	DataManager.current_hp -= amount
	print("DEBUGLOG Player: Terkena damage ", amount, " | Sisa HP: ", DataManager.current_hp)
	
	DataManager.hp_changed.emit(DataManager.current_hp, DataManager.max_hp)

	AudioManager.play_sfx(take_damage_sfx)
	_play_damage_flash()

	if DataManager.current_hp <= 0:
		is_dead = true
		_trigger_game_over()

func _play_damage_flash() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if not sprite: return

	var tween = create_tween()
	sprite.modulate = Color.RED
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.25).set_trans(Tween.TRANS_SINE)

func _trigger_game_over() -> void:
	print("DEBUGLOG Player: HP habis! Game Over.")

	var active_upgrade_screens = get_tree().get_nodes_in_group("UpgradeScreen")
	for screen in active_upgrade_screens:
		screen.queue_free()

	if game_over_scene:
		var go_ui = game_over_scene.instantiate()
		get_tree().root.add_child(go_ui)

	queue_free()