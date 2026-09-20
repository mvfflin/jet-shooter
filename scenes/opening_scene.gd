class_name OpeningScene
extends Node2D

@export_file("*.tscn") var main_menu_scene: String = "res://scenes/ui/main_menu.tscn"

@onready var glitch_overlay: ColorRect = $CanvasLayer/GlitchOverlay
@onready var intro_label: Label = $CanvasLayer/IntroLabel
@onready var title_logo: Control = $CanvasLayer/TitleLogo
@onready var crawl_container: Control = $CanvasLayer/CrawlContainer
@export var opening_bgm: AudioStream = preload("res://assets/sounds/bgm/op.mp3")

var crawl_label: RichTextLabel
var can_skip: bool = true
var is_transitioning: bool = false

func _ready() -> void:
	print("DEBUGLOG Opening: Scene _ready dimulai.")

	# PENCARIAN CRAWL LABEL
	crawl_label = $CanvasLayer/CrawlContainer.get_node_or_null("CrawlLabel") as RichTextLabel
	if not crawl_label:
		crawl_label = $CanvasLayer/CrawlContainer.get_node_or_null("CrawlTextPanel/CrawlLabel") as RichTextLabel
	if not crawl_label:
		crawl_label = $CanvasLayer/CrawlContainer.get_node_or_null("SubViewport/CrawlLabel") as RichTextLabel

	if not intro_label: print("ERROR Opening: intro_label NULL!")
	if not title_logo: print("ERROR Opening: title_logo NULL!")
	if not crawl_container: print("ERROR Opening: crawl_container NULL!")
	if not crawl_label: print("ERROR Opening: crawl_label NULL! Cek struktur node CrawlLabel di Inspector.")

	if intro_label: intro_label.modulate.a = 0.0
	
	if title_logo: 
		await get_tree().process_frame 
		var viewport_size = get_viewport_rect().size
		
		title_logo.pivot_offset = title_logo.size / 2.0
		title_logo.position = (viewport_size / 2.0) - title_logo.pivot_offset
		
		title_logo.scale = Vector2(4.0, 4.0) 
		title_logo.modulate.a = 0.0

	if crawl_container: crawl_container.visible = false
	
	_set_glitch_intensity(0.0)
	_start_opening_sequence()

func _unhandled_input(event: InputEvent) -> void:
	if can_skip and not is_transitioning:
		if event.is_pressed() and not event.is_echo():
			print("DEBUGLOG Opening: Input terdeteksi, player melakukan SKIP.")
			_go_to_main_menu()

func _set_glitch_intensity(value: float) -> void:
	if glitch_overlay and glitch_overlay.material:
		var mat = glitch_overlay.material as ShaderMaterial
		mat.set_shader_parameter("glitch_intensity", value)

func _trigger_glitch_burst(intensity: float = 0.8, duration: float = 0.15) -> void:
	_set_glitch_intensity(intensity)
	var tree = get_tree()
	if tree:
		await tree.create_timer(duration).timeout
		_set_glitch_intensity(0.0)

func _start_opening_sequence() -> void:
	print("DEBUGLOG Opening: Memulai sekuens intro...")
	var tween = create_tween()
	
	tween.tween_callback(func(): 
		print("DEBUGLOG Opening: Glitch pembuka.")
		_trigger_glitch_burst(1.0, 0.2)
	)
	
	tween.tween_callback(func(): print("DEBUGLOG Opening: Munculkan intro_label."))
	tween.tween_property(intro_label, "modulate:a", 1.0, 1.0)

	tween.tween_interval(1.0)
	tween.tween_callback(func(): _trigger_glitch_burst(0.5, 0.1))
	tween.tween_interval(1.5)
	
	tween.tween_property(intro_label, "modulate:a", 0.0, 0.8)
	
	tween.tween_callback(func():
		print("DEBUGLOG Opening: Munculkan Title Logo dengan EFEK STAMP!")
		if title_logo: 
			title_logo.modulate.a = 1.0
			_trigger_glitch_burst(1.0, 0.2)
			
			if JuiceManager:
				JuiceManager.shake_camera(15.0, 0.4)
	)

	tween.chain().tween_callback(func():
		print("DEBUGLOG Opening: Musik mulai diputar.")
		AudioManager.play_bgm(opening_bgm)
	)

	if title_logo:
		tween.tween_property(title_logo, "scale", Vector2(1.0, 1.0), 0.35)\
			.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		
		tween.tween_interval(1.5)
		
		tween.tween_callback(func(): _trigger_glitch_burst(0.6, 0.15))
		
		var fade_tween = tween.parallel()
		fade_tween.tween_property(title_logo, "scale", Vector2(1.8, 1.8), 0.8)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		fade_tween.tween_property(title_logo, "modulate:a", 0.0, 0.8)

	tween.tween_callback(func():
		_start_crawl_text()
	)

func _start_crawl_text() -> void:
	print("DEBUGLOG Opening: Mencoba menjalankan _start_crawl_text()...")
	
	if not crawl_container or not crawl_label:
		print("ERROR Opening: crawl_container atau crawl_label NULL!")
		_go_to_main_menu()
		return

	crawl_container.visible = true
	
	crawl_label.position.y = 1080.0
	
	var content_height = crawl_label.get_content_height()
	var target_y = -content_height - 200.0
	var scroll_duration = 35.0
	
	var crawl_tween = create_tween()
	crawl_tween.tween_property(crawl_label, "position:y", target_y, scroll_duration)
	crawl_tween.finished.connect(func():
		print("DEBUGLOG Opening: Crawl Text selesai!")
		_go_to_main_menu()
	)

func _go_to_main_menu() -> void:
	if is_transitioning: return
	is_transitioning = true
	
	print("DEBUGLOG Opening: Berpindah scene ke Main Menu -> ", main_menu_scene)
	_set_glitch_intensity(0.0)
	
	var fade_tween = create_tween()
	var bg_rect = get_node_or_null("CanvasLayer/ColorRect")
	if bg_rect:
		fade_tween.tween_property(bg_rect, "color:a", 1.0, 1.0)
		fade_tween.finished.connect(func():
			SceneTransition.change_scene(main_menu_scene)
		)
	else:
		SceneTransition.change_scene(main_menu_scene)