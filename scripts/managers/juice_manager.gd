extends Node

# Signal untuk trigger screen shake
signal camera_shake_requested(intensity: float, duration: float)
signal camera_zoom_punch_requested(zoom_factor: float, duration: float)

# HIT-STOP / FREEZE FRAME
func hit_stop(duration: float = 0.05, time_scale: float = 0.05) -> void:
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale, true, false, true).timeout
	Engine.time_scale = 1.0

# SCREEN SHAKE
func shake_camera(intensity: float = 5.0, duration: float = 0.2) -> void:
	camera_shake_requested.emit(intensity, duration)

# CAMERA PUNCH / ZOOM
func zoom_punch(zoom_factor: float = 0.05, duration: float = 0.15) -> void:
	camera_zoom_punch_requested.emit(zoom_factor, duration)