class_name WaveManager
extends Node

signal wave_started(wave_num: int)
signal wave_completed(wave_num: int)

@export var wave_configs: Array[WaveConfig] = []
@export var alien_base_scene: PackedScene = preload("res://scenes/entities/aliens/alien_base.tscn")
@export var asteroid_scene: PackedScene = preload("res://scenes/entities/asteroids/asteroids.tscn")
@export var boss_scene: PackedScene = preload("res://scenes/entities/boss/boss.tscn")
@export var wave: AudioStream = preload("res://assets/sounds/bgm/wave.wav")
@export var boss: AudioStream = preload("res://assets/sounds/bgm/boss.wav")
@export var spawn: AudioStream = preload("res://assets/sounds/sfx/explosion.wav")
@export var glitch: AudioStream = preload("res://assets/sounds/sfx/glitch2.mp3")

@export var stat_buff_per_wave: float = 0.05
@export var wave_banner_label: Label
@export var dialog_box: Control 

var alien_scripts = {
	"skitter": preload("res://scripts/entities/aliens/skitter.gd"),
	"ocular drone": preload("res://scripts/entities/aliens/ocular_drone.gd"),
	"spawnling": preload("res://scripts/entities/aliens/spawnling.gd"),
	"ring wisp": preload("res://scripts/entities/aliens/ring_wisp.gd"),
	"leech spore": preload("res://scripts/entities/aliens/leech_spore.gd")
}

var current_wave_idx: int = 0
var current_config: WaveConfig

var wave_timer: Timer
var alien_spawn_timer: Timer
var asteroid_spawn_timer: Timer

func _ready() -> void:
	add_to_group("WaveManager")
	
	wave_timer = Timer.new()
	wave_timer.one_shot = true
	wave_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	add_child(wave_timer)
	
	alien_spawn_timer = Timer.new()
	alien_spawn_timer.one_shot = true
	alien_spawn_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	alien_spawn_timer.timeout.connect(_spawn_periodic_alien)
	add_child(alien_spawn_timer)
	
	asteroid_spawn_timer = Timer.new()
	asteroid_spawn_timer.one_shot = true
	asteroid_spawn_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	asteroid_spawn_timer.timeout.connect(_spawn_periodic_asteroid)
	add_child(asteroid_spawn_timer)

func start_wave(idx: int) -> void:
	current_wave_idx = idx
	
	# Deteksi BOSS Wave (Wave 5)
	if idx == 4 or (idx < wave_configs.size() and wave_configs[idx].wave_number == 5):
		_start_boss_wave_sequence()
		return

	if idx >= wave_configs.size():
		print("Semua Wave Selesai!")
		alien_spawn_timer.stop()
		asteroid_spawn_timer.stop()
		return

	if wave:
		AudioManager.play_bgm(wave, -4.0, 1.0)
	current_config = wave_configs[idx]
	wave_started.emit(current_config.wave_number)
	
	wave_timer.start(current_config.duration_seconds)
	
	_spawn_initial_asteroids(current_config.initial_asteroids_count)
	_schedule_next_spawn(alien_spawn_timer, current_config.start_alien_interval, current_config.end_alien_interval)
	_schedule_next_spawn(asteroid_spawn_timer, current_config.start_asteroid_interval, current_config.end_asteroid_interval)
	
	if DataManager:
		DataManager.waves_survived = current_wave_idx
	_show_slam_banner("WAVE " + str(current_wave_idx + 1))

func _start_boss_wave_sequence() -> void:
	print("DEBUGLOG BossSeq: === MEMULAI BOSS WAVE SEQUENCE ===")
	
	wave_timer.stop()
	if DataManager:
		DataManager.waves_survived = 4
	wave_started.emit(5)
	
	AudioManager.stop_bgm(0.8)

	var player = get_tree().get_first_node_in_group("Player")
	
	var main_scene = get_parent()
	var glitch_overlay = main_scene.get_node_or_null("CanvasLayer/GlitchOverlay")

	if JuiceManager:
		JuiceManager.shake_camera(8.0, 1.0)
		
	if dialog_box and dialog_box.has_method("show_dialog"):
		await dialog_box.show_dialog("DANGER! DANGER! DANGER!", Color.RED, 2.0)

	if glitch_overlay and glitch_overlay.material:
		AudioManager.play_sfx(glitch)
		glitch_overlay.visible = true
		(glitch_overlay.material as ShaderMaterial).set_shader_parameter("glitch_intensity", 0.5)

	if JuiceManager:
		JuiceManager.shake_camera(12.0, 1.2)
		
	if dialog_box and dialog_box.has_method("show_dialog"):
		await dialog_box.show_dialog("MAXIMUM THREATS LEVEL: CODE NAME TITAN", Color.RED, 2.5)

	if glitch_overlay and glitch_overlay.material:
		AudioManager.play_sfx(glitch)
		(glitch_overlay.material as ShaderMaterial).set_shader_parameter("glitch_intensity", 0.85)

	_show_slam_banner("BOSS WAVE")

	var viewport_size = get_viewport().get_visible_rect().size
	var map_center = viewport_size / 2.0
	var boss_spawn_pos = map_center

	if is_instance_valid(player):
		var dir_to_center = (map_center - player.global_position).normalized()
		boss_spawn_pos = map_center + (dir_to_center * 350.0)
		boss_spawn_pos.x = clamp(boss_spawn_pos.x, 100.0, viewport_size.x - 100.0)
		boss_spawn_pos.y = clamp(boss_spawn_pos.y, 100.0, viewport_size.y - 100.0)

	if main_scene and main_scene.has_method("focus_boss_entrance"):
		main_scene.focus_boss_entrance(boss_spawn_pos, true)
	
	await get_tree().create_timer(0.8).timeout
	_spawn_particles(main_scene, boss_spawn_pos)
	AudioManager.play_sfx(spawn)
	
	if JuiceManager:
		JuiceManager.shake_camera(25.0, 0.8)

	var boss_instance: Node2D = null
	if boss_scene:
		boss_instance = boss_scene.instantiate()
		boss_instance.global_position = boss_spawn_pos
		var ysort_node = main_scene.get_node_or_null("YSort")
		if ysort_node:
			ysort_node.add_child(boss_instance)
		else:
			main_scene.add_child(boss_instance)

		if boss_instance.has_signal("boss_defeated"):
			boss_instance.boss_defeated.connect(_on_boss_defeated)

	if glitch_overlay and glitch_overlay.material:
		(glitch_overlay.material as ShaderMaterial).set_shader_parameter("glitch_intensity", 0.0)

	if boss:
		AudioManager.play_bgm(boss, 0.0, 0.3)

	await get_tree().create_timer(0.5).timeout

	if dialog_box and dialog_box.has_method("show_dialog"):
		await dialog_box.show_dialog("Cih... Bahkan code name Titan pun ada di sini!", Color.YELLOW, 2.0)
		await dialog_box.show_dialog("Aku akan melindungimu sampai tetes darah penghabisan...", Color.YELLOW, 2.0)
		await dialog_box.show_dialog("EMILY!!!!!", Color.YELLOW, 1.5)

	if main_scene and main_scene.has_method("focus_boss_entrance"):
		main_scene.focus_boss_entrance(boss_spawn_pos, false)

	if current_wave_idx < wave_configs.size():
		current_config = wave_configs[current_wave_idx]
	elif not wave_configs.is_empty():
		current_config = wave_configs.back()

	if current_config:
		_schedule_next_spawn(alien_spawn_timer, current_config.start_alien_interval, current_config.end_alien_interval)
		_schedule_next_spawn(asteroid_spawn_timer, current_config.start_asteroid_interval, current_config.end_asteroid_interval)
	
	print("DEBUGLOG BossSeq: === BOSS WAVE SEQUENCE SELESAI ===")

func _spawn_particles(parent_node: Node, pos: Vector2) -> void:
	var particles = GPUParticles2D.new()
	var mat = ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 10.0
	mat.direction = Vector3.ZERO
	mat.spread = 180.0
	mat.initial_velocity_min = 150.0
	mat.initial_velocity_max = 350.0
	mat.gravity = Vector3.ZERO
	mat.scale_min = 3.0
	mat.scale_max = 6.0
	mat.color = Color(0.1, 0.6, 1.0, 1.0) 
	
	particles.process_material = mat
	particles.amount = 60
	particles.lifetime = 0.8
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.global_position = pos
	
	parent_node.add_child(particles)
	particles.emitting = true
	get_tree().create_timer(1.0).timeout.connect(particles.queue_free)

func _on_boss_defeated() -> void:
	wave_completed.emit(5)
	SceneTransition.change_scene("res://scenes/ui/winning_credit.tscn", 1.0)

func _spawn_initial_asteroids(count: int) -> void:
	if not asteroid_scene: return
	for i in range(count):
		var asteroid = asteroid_scene.instantiate()
		asteroid.global_position = _get_random_inside_spawn_position(120.0, 100.0)
		get_parent().call_deferred("add_child", asteroid)

func _spawn_periodic_alien() -> void:
	if current_config and not current_config.allowed_aliens.is_empty() and alien_base_scene:
		var chosen_data: AlienData = current_config.allowed_aliens.pick_random()
		var buffed_data: AlienData = chosen_data.duplicate() as AlienData
		var multiplier = 1.0 + (current_wave_idx * stat_buff_per_wave)
		
		buffed_data.max_hp *= multiplier
		buffed_data.speed *= (1.0 + (current_wave_idx * (stat_buff_per_wave * 0.5)))
		var alien_key = buffed_data.name.to_lower()
		
		var group_count = randi_range(3, 5) if alien_key == "skitter" else 1
		var base_spawn_pos = _get_random_outside_spawn_position()
		
		for i in range(group_count):
			var alien = alien_base_scene.instantiate() as AlienBase
			if alien_scripts.has(alien_key):
				alien.set_script(alien_scripts[alien_key])
				
			alien.data = buffed_data
			var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20)) if group_count > 1 else Vector2.ZERO
			alien.global_position = base_spawn_pos + offset
			
			get_parent().add_child(alien)
			if alien.has_method("setup_visual"):
				alien.setup_visual()
				
	_schedule_next_spawn(alien_spawn_timer, current_config.start_alien_interval, current_config.end_alien_interval)

func _spawn_periodic_asteroid() -> void:
	if asteroid_scene:
		var asteroid = asteroid_scene.instantiate()
		asteroid.global_position = _get_random_outside_spawn_position()
		get_parent().add_child(asteroid)
		
	_schedule_next_spawn(asteroid_spawn_timer, current_config.start_asteroid_interval, current_config.end_asteroid_interval)

func _schedule_next_spawn(timer: Timer, start_range: Vector2, end_range: Vector2) -> void:
	if not current_config: return
	
	var total_duration = current_config.duration_seconds if current_config else 60.0
	var time_left = wave_timer.time_left if not wave_timer.is_stopped() else 0.0
	var time_passed = total_duration - time_left
	var progress = clamp(time_passed / total_duration, 0.0, 1.0)
	
	var current_min = lerp(start_range.x, end_range.x, progress)
	var current_max = lerp(start_range.y, end_range.y, progress)
	
	timer.start(randf_range(current_min, current_max))

func _get_random_inside_spawn_position(margin: float = 100.0, min_player_dist: float = 100.0) -> Vector2:
	var viewport_rect = get_viewport().get_visible_rect()
	var safe_margin_x = min(margin, viewport_rect.size.x * 0.25)
	var safe_margin_y = min(margin, viewport_rect.size.y * 0.25)
	
	var player = get_tree().get_first_node_in_group("Player")
	var player_pos = player.global_position if player else viewport_rect.size / 2.0
	var candidate_pos = Vector2.ZERO
	var is_safe = false
	var attempts = 0
	
	while not is_safe and attempts < 20:
		candidate_pos = Vector2(
			randf_range(safe_margin_x, viewport_rect.size.x - safe_margin_x),
			randf_range(safe_margin_y, viewport_rect.size.y - safe_margin_y)
		)
		if candidate_pos.distance_to(player_pos) >= min_player_dist:
			is_safe = true
		attempts += 1

	return candidate_pos

func _get_random_outside_spawn_position() -> Vector2:
	var viewport_rect = get_viewport().get_visible_rect()
	var spawn_pos = Vector2.ZERO
	var margin = 60.0
	var side = randi() % 4
	match side:
		0:
			spawn_pos.x = randf_range(0, viewport_rect.size.x)
			spawn_pos.y = -margin
		1:
			spawn_pos.x = randf_range(0, viewport_rect.size.x)
			spawn_pos.y = viewport_rect.size.y + margin
		2:
			spawn_pos.x = -margin
			spawn_pos.y = randf_range(0, viewport_rect.size.y)
		3:
			spawn_pos.x = viewport_rect.size.x + margin
			spawn_pos.y = randf_range(0, viewport_rect.size.y)
	return spawn_pos

func _on_wave_timer_timeout() -> void:
	wave_completed.emit(current_config.wave_number)
	current_wave_idx += 1
	start_wave(current_wave_idx)

func _show_slam_banner(text_to_show: String) -> void:
	if not wave_banner_label: return
	wave_banner_label.text = text_to_show
	wave_banner_label.visible = true
	wave_banner_label.pivot_offset = wave_banner_label.size / 2.0
	wave_banner_label.scale = Vector2(4.0, 4.0)
	wave_banner_label.modulate.a = 0.0
	
	var tween = create_tween()
	tween.parallel().tween_property(wave_banner_label, "scale", Vector2(1.0, 1.0), 0.25)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(wave_banner_label, "modulate:a", 1.0, 0.1)
	tween.tween_interval(1.5)
	tween.tween_property(wave_banner_label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): wave_banner_label.visible = false)

func get_time_left() -> float:
	return wave_timer.time_left