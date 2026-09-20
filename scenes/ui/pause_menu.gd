extends Control

@onready var resume_button: Button = $MarginContainer/VBoxContainer/MenuButtons/ResumeButton
@onready var restart_button: Button = $MarginContainer/VBoxContainer/MenuButtons/RestartButton
@onready var main_menu_button: Button = $MarginContainer/VBoxContainer/MenuButtons/MainMenuButton
@onready var wave_label: Label = $MarginContainer/VBoxContainer/SubtitleLabel

func _ready() -> void:
	print("DEBUGLOG PauseMenu: _ready() dipanggil!")
	hide()
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if DataManager:
		if wave_label: 
			wave_label.text = "Current Wave: " + str(DataManager.waves_survived + 1)

	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		print("DEBUGLOG PauseMenu: Tombol Pause/Escape Terdeteksi!")
		_toggle_pause()
		get_viewport().set_input_as_handled()

func _toggle_pause() -> void:
	var is_paused = get_tree().paused
	print("DEBUGLOG PauseMenu: Toggling pause, status awal paused = ", is_paused)
	
	if is_paused:
		get_tree().paused = false
		hide()
		print("DEBUGLOG PauseMenu: Game RESUMED!")
	else:
		if DataManager and wave_label:
			wave_label.text = "Current Wave: " + str(DataManager.waves_survived + 1)
		get_tree().paused = true
		show()
		print("DEBUGLOG PauseMenu: Game PAUSED!")

func _on_resume_pressed() -> void:
	print("DEBUGLOG PauseMenu: Tombol Resume Ditekan")
	get_tree().paused = false
	hide()

func _on_restart_pressed() -> void:
	print("DEBUGLOG GameOverScreen: Restarting Game...")
	
	get_tree().paused = false
	
	AudioManager.stop_bgm(0.1)

	if DataManager and DataManager.has_method("reset_data"):
		DataManager.reset_data()
		
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.3)
	fade_tween.finished.connect(func():
		get_tree().reload_current_scene()
	)

func _on_main_menu_pressed() -> void:
	print("DEBUGLOG PauseMenu: Tombol Main Menu Ditekan")
	get_tree().paused = false
	AudioManager.stop_bgm(0.5)
	SceneTransition.change_scene("res://scenes/ui/main_menu.tscn", 1.0)
