extends State

var can_transition: bool = false
@export var dash_sfx: AudioStream = preload("res://assets/sounds/sfx/dash.wav")

func enter() -> void:
	super.enter()
	animation_player.play("Glowing")
	await dash()
	can_transition = true

func dash() -> void:
	if not is_instance_valid(player): return

	AudioManager.play_sfx(dash_sfx)
	var tween = create_tween()
	tween.tween_property(owner, "global_position", player.global_position, 0.8)
	await tween.finished
	
func transition() -> void:
	if can_transition:
		can_transition = false
		get_parent().change_state("Follow")