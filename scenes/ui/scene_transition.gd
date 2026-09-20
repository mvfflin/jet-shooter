extends Control

@onready var rect: ColorRect = $ColorRect

# Layar transisi buat memperhalus
func change_scene(target_scene_path: String, duration: float = 0.8) -> void:
	rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	AudioManager.stop_bgm(duration)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(rect, "color:a", 1.0, duration)
	await tween.finished
	
	get_tree().change_scene_to_file(target_scene_path)
	
	var tween_in = create_tween()
	tween_in.tween_property(rect, "color:a", 0.0, duration)
	await tween_in.finished
	
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE