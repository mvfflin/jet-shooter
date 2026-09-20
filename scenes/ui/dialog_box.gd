extends Control

@onready var dialog_label: Label = $MarginContainer/PanelContainer/MarginContainer/DialogLabel

@export var characters_per_second: float = 30.0 

func _ready() -> void:
	hide() 

func show_dialog(text_to_show: String, text_color: Color = Color.WHITE, display_duration: float = 3.5) -> void:
	dialog_label.text = text_to_show
	dialog_label.add_theme_color_override("font_color", text_color)
	dialog_label.modulate = Color.WHITE
	
	dialog_label.visible_ratio = 0.0
	show()
	
	var total_chars = text_to_show.length()
	var typing_duration = total_chars / characters_per_second
	
	var tween = create_tween()
	tween.tween_property(dialog_label, "visible_ratio", 1.0, typing_duration)
	
	var timer = get_tree().create_timer(display_duration)
	var waiting_input = true

	await get_tree().process_frame

	while waiting_input:
		await get_tree().process_frame

		if timer.time_left <= 0:
			waiting_input = false
		elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("click"):
			waiting_input = false

	hide()
