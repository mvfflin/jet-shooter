class_name WaveManager
extends Node

signal wave_started(wave_num: int)
signal wave_completed(wave_num: int)

@export var wave_configs: Array[WaveConfig] = []
@export var alien_base_scene: PackedScene = preload("res://scenes/entities/aliens/alien_base.tscn")
@export var asteroid_scene: PackedScene = preload("res://scenes/entities/asteroids/asteroids.tscn")
@export var skitter_script: Script = preload("res://scripts/entities/aliens/skitter.gd")

var current_wave_idx: int = 0
var current_config: WaveConfig

var wave_timer: Timer
var alien_spawn_timer: Timer
var asteroid_spawn_timer: Timer

func _ready() -> void:
	add_to_group("WaveManager")
	
	# Timer Durasi Wave
	wave_timer = Timer.new()
	wave_timer.one_shot = true
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	add_child(wave_timer)
	
	# Timer Spawn Alien
	alien_spawn_timer = Timer.new()
	alien_spawn_timer.one_shot = true
	alien_spawn_timer.timeout.connect(_spawn_periodic_alien)
	add_child(alien_spawn_timer)
	
	# Timer Spawn Asteroid
	asteroid_spawn_timer = Timer.new()
	asteroid_spawn_timer.one_shot = true
	asteroid_spawn_timer.timeout.connect(_spawn_periodic_asteroid)
	add_child(asteroid_spawn_timer)
	
	start_wave(0)

func start_wave(idx: int) -> void:
	if idx >= wave_configs.size():
		print("Semua Wave Selesai / Lanjut ke Boss Wave!")
		alien_spawn_timer.stop()
		asteroid_spawn_timer.stop()
		return
		
	current_wave_idx = idx
	current_config = wave_configs[idx]
	wave_started.emit(current_config.wave_number)
	
	wave_timer.start(current_config.duration_seconds)
	
	# 1. Spawn Asteroid Awal di Dalam Map
	_spawn_initial_asteroids(current_config.initial_asteroids_count)
	
	# 2. Set First Spawn
	_schedule_next_spawn(alien_spawn_timer, current_config.start_alien_interval, current_config.end_alien_interval)
	_schedule_next_spawn(asteroid_spawn_timer, current_config.start_asteroid_interval, current_config.end_asteroid_interval)
	
	print("Wave ", current_config.wave_number, " Dimulai! Durasi: ", current_config.duration_seconds, "s")

# Initial spawn asteroid
func _spawn_initial_asteroids(count: int) -> void:
	if not asteroid_scene: return
	
	print("DEBUGLOG: Memunculkan ", count, " Asteroid awal di dalam map.")
	for i in range(count):
		var asteroid = asteroid_scene.instantiate()
		asteroid.global_position = _get_random_inside_spawn_position(200.0)
		get_parent().call_deferred("add_child", asteroid)

# Periodic spawn alien
func _spawn_periodic_alien() -> void:
	if current_config and not current_config.allowed_aliens.is_empty() and alien_base_scene:
		var chosen_data: AlienData = current_config.allowed_aliens.pick_random()
		var is_skitter = (chosen_data.name.to_lower() == "skitter")
		var group_count = randi_range(5, 6) if is_skitter else 1
		var base_spawn_pos = _get_random_outside_spawn_position()
		
		for i in range(group_count):
			var alien = alien_base_scene.instantiate()
			if skitter_script and is_skitter:
				alien.set_script(skitter_script)
			alien.data = chosen_data
			
			var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30)) if group_count > 1 else Vector2.ZERO
			alien.global_position = base_spawn_pos + offset
			
			get_parent().add_child(alien)
			if alien.has_method("setup_visual"):
				alien.setup_visual()
				
	_schedule_next_spawn(alien_spawn_timer, current_config.start_alien_interval, current_config.end_alien_interval)

# Periodic spawn asteroid
func _spawn_periodic_asteroid() -> void:
	if asteroid_scene:
		var asteroid = asteroid_scene.instantiate()

		asteroid.global_position = _get_random_outside_spawn_position()
		get_parent().add_child(asteroid)
		print("DEBUGLOG: Periodic Asteroid dispawn dari LUAR map: ", asteroid.global_position)
		
	_schedule_next_spawn(asteroid_spawn_timer, current_config.start_asteroid_interval, current_config.end_asteroid_interval)

# Set timer spawn menjadi dinamis, jadi tidak terpaku pada detik dan pola yang sama
func _schedule_next_spawn(timer: Timer, start_range: Vector2, end_range: Vector2) -> void:
	if not current_config or wave_timer.is_stopped(): return

	var time_passed = current_config.duration_seconds - wave_timer.time_left
	var progress = clamp(time_passed / current_config.duration_seconds, 0.0, 1.0)
	
	var current_min = lerp(start_range.x, end_range.x, progress)
	var current_max = lerp(start_range.y, end_range.y, progress)
	
	var random_wait_time = randf_range(current_min, current_max)
	timer.start(random_wait_time)

# Spawn postions
# Asteroid
func _get_random_inside_spawn_position(margin: float = 100.0) -> Vector2:
	var viewport_rect = get_viewport().get_visible_rect()
	var safe_margin_x = min(margin, viewport_rect.size.x * 0.25)
	var safe_margin_y = min(margin, viewport_rect.size.y * 0.25)
	
	return Vector2(
		randf_range(safe_margin_x, viewport_rect.size.x - safe_margin_x),
		randf_range(safe_margin_y, viewport_rect.size.y - safe_margin_y)
	)

# Alien
func _get_random_outside_spawn_position() -> Vector2:
	var viewport_rect = get_viewport().get_visible_rect()
	var spawn_pos = Vector2.ZERO
	var margin = 60.0
	
	var side = randi() % 4
	match side:
		0: # Atas
			spawn_pos.x = randf_range(0, viewport_rect.size.x)
			spawn_pos.y = -margin
		1: # Bawah
			spawn_pos.x = randf_range(0, viewport_rect.size.x)
			spawn_pos.y = viewport_rect.size.y + margin
		2: # Kiri
			spawn_pos.x = -margin
			spawn_pos.y = randf_range(0, viewport_rect.size.y)
		3: # Kanan
			spawn_pos.x = viewport_rect.size.x + margin
			spawn_pos.y = randf_range(0, viewport_rect.size.y)
			
	return spawn_pos

func _on_wave_timer_timeout() -> void:
	print("Wave ", current_config.wave_number, " Selesai!")
	wave_completed.emit(current_config.wave_number)
	
	current_wave_idx += 1
	start_wave(current_wave_idx)

func get_time_left() -> float:
	return wave_timer.time_left
