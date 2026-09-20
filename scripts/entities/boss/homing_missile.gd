extends State

@export var bullet_node: PackedScene
@export var missile: AudioStream = preload("res://assets/sounds/sfx/missile.wav")
var can_transition: bool = false

func enter() -> void:
	super.enter()
	animation_player.play("Ranged_attack")
	AudioManager.play_sfx(missile)
	await animation_player.animation_finished
	shoot()
	can_transition = true

func shoot() -> void:
	if bullet_node:
		var bullet = bullet_node.instantiate()
		bullet.global_position = owner.global_position 
		get_tree().current_scene.add_child(bullet)
	
func transition() -> void:
	if can_transition:
		can_transition = false
		get_parent().change_state("Dash")