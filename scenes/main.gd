extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var player: Node2D = $Player
@onready var ysort: Node2D = $YSort
@onready var wave_manager: WaveManager = $WaveManager
@onready var hud: Control = $CanvasLayer/Hud
@onready var dialog_box: Control = $CanvasLayer/DialogBox

var _shake_intensity: float = 0.0
var _shake_timer: float = 0.0
var _base_zoom: Vector2 = Vector2.ONE

func _ready() -> void:
	var viewport_size := get_viewport_rect().size

	camera.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
	camera.global_position = viewport_size / 2.0
	camera.make_current()

	camera.limit_left = -10000000
	camera.limit_top = -10000000
	camera.limit_right = 10000000
	camera.limit_bottom = 10000000

	_base_zoom = camera.zoom
	
	if JuiceManager:
		JuiceManager.camera_shake_requested.connect(_on_shake_requested)
		JuiceManager.camera_zoom_punch_requested.connect(_on_zoom_punch_requested)

	_play_opening_cutscene()

func _play_opening_cutscene() -> void:
	var viewport_size = get_viewport_rect().size
	
	if is_instance_valid(hud):
		hud.hide()
	
	player.rotation = -PI / 2.0
	
	var spawn_pos = Vector2(viewport_size.x / 2.0, viewport_size.y - 100.0)
	
	var forward_pos = Vector2(viewport_size.x / 2.0, viewport_size.y - 300.0)
	
	player.global_position = spawn_pos
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	
	_zoom_camera_to_player(spawn_pos, true, 0.8)
	await get_tree().create_timer(0.4).timeout
	
	if is_instance_valid(dialog_box) and dialog_box.has_method("show_dialog"):
		await dialog_box.show_dialog("Bertahanlah Emily, kau adalah satu-satunya harapan kita saat ini...", Color.YELLOW, 4.0)
			
		await dialog_box.show_dialog("Aku yakin dunia ini bisa kembali bersinar olehmu, jadi bertahanlah!", Color.YELLOW, 4.0)

	var tween_fly = create_tween()
	tween_fly.tween_property(player, "global_position", forward_pos, 1.0)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	await get_tree().create_timer(0.4).timeout
	await _fade_screen(true, 0.5) 
	
	player.global_position = spawn_pos
	_zoom_camera_to_player(Vector2.ZERO, false, 0.1) 
	
	await get_tree().create_timer(0.2).timeout
	await _fade_screen(false, 0.5) 
	
	if is_instance_valid(hud):
		hud.show()
		
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	
	if is_instance_valid(wave_manager):
		wave_manager.start_wave(0)

func _zoom_camera_to_player(player_pos: Vector2, zoom_in: bool, duration: float) -> void:
	if not is_instance_valid(camera): return
	
	var viewport_center := get_viewport_rect().size / 2.0
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	if zoom_in:
		var target_offset = player_pos - viewport_center
		tween.tween_property(camera, "offset", target_offset, duration)
		tween.tween_property(camera, "zoom", _base_zoom * 1.5, duration)
	else:
		tween.tween_property(camera, "offset", Vector2.ZERO, duration)
		tween.tween_property(camera, "zoom", _base_zoom, duration)


func _fade_screen(fade_to_black: bool, duration: float) -> Signal:
	var canvas_layer = $CanvasLayer
	var fader = canvas_layer.get_node_or_null("ScreenFader") as ColorRect
	
	if not fader:
		fader = ColorRect.new()
		fader.name = "ScreenFader"
		fader.set_anchors_preset(Control.PRESET_FULL_RECT)
		fader.color = Color(0, 0, 0, 0)
		fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
		canvas_layer.add_child(fader)
	
	var target_alpha = 1.0 if fade_to_black else 0.0
	var tween = create_tween()
	tween.tween_property(fader, "color:a", target_alpha, duration)
	
	return tween.finished

func _on_shake_requested(intensity: float, duration: float) -> void:
	_shake_intensity = intensity
	_shake_timer = duration

func _on_zoom_punch_requested(zoom_factor: float, duration: float) -> void:
	if not is_instance_valid(camera): return
	var target_zoom = _base_zoom + Vector2(zoom_factor, zoom_factor)
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "zoom", target_zoom, duration * 0.3)
	tween.tween_property(camera, "zoom", _base_zoom, duration * 0.7)