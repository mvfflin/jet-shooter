extends AlienBase

@export var skitter_script: Script = preload("res://scripts/entities/aliens/skitter.gd")
@export var skitter_data: AlienData = preload("res://resources/aliens/skitter.tres")

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player): return
	
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * (data.speed if data else 60.0)
	rotation = dir.angle()
	move_and_slide()

# Override die() biar munculin 2 skitter pas mati
func die() -> void:
	_spawn_minions()
	super.die()

func _spawn_minions() -> void:
	var base_scene = load("res://scenes/entities/aliens/alien_base.tscn")
	if not base_scene: return
	
	for i in range(2):
		var minion = base_scene.instantiate() as AlienBase
		if skitter_script: minion.set_script(skitter_script)
		if skitter_data: minion.data = skitter_data
		
		var offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
		minion.global_position = global_position + offset
		get_parent().call_deferred("add_child", minion)