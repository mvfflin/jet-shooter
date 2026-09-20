class_name MainMenu
extends Control

@export_file("*.tscn") var game_scene_path: String = "res://scenes/main.tscn"
@export var bgm: AudioStream = preload("res://assets/sounds/bgm/main_menu.wav")

# Node Referensi Tombol Utama
@onready var play_button: Button = $MarginContainer/VBoxContainer/MenuButtons/PlayButton
@onready var credits_button: Button = $MarginContainer/VBoxContainer/MenuButtons/CreditsButton
@onready var guide_button: Button = $MarginContainer/VBoxContainer/MenuButtons/GuideButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/MenuButtons/QuitButton

# Node Panel Pop-up
@onready var credits_panel: PanelContainer = $CreditsPanel
@onready var guide_panel: PanelContainer = $GuidePanel
@onready var close_credits_btn: Button = $CreditsPanel/MarginContainer/VBoxContainer/CloseCreditsBtn
@onready var close_guide_btn: Button = $GuidePanel/MarginContainer/VBoxContainer/CloseGuideBtn

func _ready() -> void:
	AudioManager.play_bgm(bgm)

	credits_panel.visible = false
	guide_panel.visible = false

	# Connect signal tombol
	play_button.pressed.connect(_on_play_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	guide_button.pressed.connect(_on_guide_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	close_credits_btn.pressed.connect(func(): _toggle_panel(credits_panel, false))
	close_guide_btn.pressed.connect(func(): _toggle_panel(guide_panel, false))

	var buttons = [play_button, credits_button, guide_button, quit_button, close_credits_btn, close_guide_btn]
	for btn in buttons:
		if btn:
			btn.focus_mode = Control.FOCUS_NONE
			btn.pivot_offset = btn.size / 2.0
			btn.mouse_entered.connect(func(): _on_button_hover(btn))
			btn.mouse_exited.connect(func(): _on_button_exit(btn))

func _on_play_pressed() -> void:
	print("DEBUGLOG MainMenu: Memulai Game...")
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.finished.connect(func():
		SceneTransition.change_scene(game_scene_path)
	)

func _on_credits_pressed() -> void:
	_toggle_panel(credits_panel, true)

func _on_guide_pressed() -> void:
	_toggle_panel(guide_panel, true)

func _on_quit_pressed() -> void:
	print("DEBUGLOG MainMenu: Keluar dari Game.")
	get_tree().quit()

func _toggle_panel(panel: Control, show_panel: bool) -> void:
	if show_panel:
		panel.visible = true
		panel.modulate.a = 0.0
		var t = create_tween()
		t.tween_property(panel, "modulate:a", 1.0, 0.25)
	else:
		var t = create_tween()
		t.tween_property(panel, "modulate:a", 0.0, 0.2)
		t.finished.connect(func(): panel.visible = false)

func _on_button_hover(btn: Button) -> void:
	btn.pivot_offset = btn.size / 2.0
	var t = create_tween()
	t.tween_property(btn, "scale", Vector2(1.08, 1.08), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_button_exit(btn: Button) -> void:
	var t = create_tween()
	t.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
