extends Control

@onready var credit_content: Control = $CreditContent
@onready var vbox_container: VBoxContainer = $CreditContent/VBoxContainer

@export var credit_duration: float = 30.0 
@export var bgm_ending: AudioStream = preload("res://assets/sounds/bgm/wave.wav") 

var is_skipping: bool = false
var tween: Tween

func _ready() -> void:
	if bgm_ending:
		AudioManager.play_bgm(bgm_ending, 0.0, 1.0)

	var viewport_height = get_viewport_rect().size.y
	credit_content.position.y = viewport_height

	await get_tree().process_frame
	
	var end_y_pos = -vbox_container.size.y - 50.0

	tween = create_tween()
	
	tween.tween_property(credit_content, "position:y", end_y_pos, credit_duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)
	
	tween.finished.connect(_on_credit_finished)

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.is_pressed() and not is_skipping:
			print("DEBUGLOG: Credit diskip oleh player!")
			_return_to_main_menu()

func _on_credit_finished() -> void:
	if not is_skipping:
		_return_to_main_menu()

func _return_to_main_menu() -> void:
	is_skipping = true
	
	if tween and tween.is_running():
		tween.kill()
	
	AudioManager.stop_bgm(0.8)
	
	SceneTransition.change_scene("res://scenes/opening_scene.tscn", 0.8)