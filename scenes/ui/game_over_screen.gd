class_name GameOverScreen
extends Control

@export_file("*.tscn") var main_game_scene: String = "res://scenes/main.tscn"
@export_file("*.tscn") var main_menu_scene: String = "res://scenes/ui/main_menu.tscn"

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var wave_label: Label = $MarginContainer/VBoxContainer/StatsContainer/WaveReachedLabel
@onready var restart_button: Button = $MarginContainer/VBoxContainer/MenuButtons/RestartButton
@onready var main_menu_button: Button = $MarginContainer/VBoxContainer/MenuButtons/MainMenuButton
@export var death_sfx: AudioStream = preload("res://assets/sounds/sfx/death.wav")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	get_tree().paused = true

	if death_sfx:
		AudioManager.play_sfx(death_sfx)

	if DataManager:
		if wave_label: wave_label.text = "Waves Survived: " + str(DataManager.waves_survived)

	restart_button.custom_minimum_size.x = 200
	main_menu_button.custom_minimum_size.x = 200

	restart_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	main_menu_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	var buttons = [restart_button, main_menu_button]
	for btn in buttons:
		if btn:
			btn.focus_mode = Control.FOCUS_NONE 
			btn.pivot_offset = btn.size / 2.0
			btn.mouse_entered.connect(func(): _on_button_hover(btn))
			btn.mouse_exited.connect(func(): _on_button_exit(btn))

	_play_entrance_animation()

func _play_entrance_animation() -> void:
	modulate.a = 0.0
	var tween = create_tween().set_parallel(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, 0.6)

	if title_label:
		title_label.pivot_offset = title_label.size / 2.0
		title_label.scale = Vector2(1.5, 1.5)
		tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_restart_pressed() -> void:
	print("DEBUGLOG GameOverScreen: Restarting Game...")

	AudioManager.stop_bgm(0.1)

	if DataManager and DataManager.has_method("reset_data"):
		DataManager.reset_data()

	var fade_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.3)
	fade_tween.finished.connect(func():
		get_tree().paused = false
		get_tree().reload_current_scene()
	)

func _on_main_menu_pressed() -> void:
	print("DEBUGLOG GameOverScreen: Returning to Main Menu...")

	if DataManager and DataManager.has_method("reset_data"):
		DataManager.reset_data()

	var fade_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.3)
	fade_tween.finished.connect(func():
		get_tree().paused = false
		SceneTransition.change_scene(main_menu_scene)
	)

func _on_button_hover(btn: Button) -> void:
	btn.pivot_offset = btn.size / 2.0
	var t = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(btn, "scale", Vector2(1.08, 1.08), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_button_exit(btn: Button) -> void:
	var t = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)