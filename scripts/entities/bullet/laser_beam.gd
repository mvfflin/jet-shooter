class_name LaserBeam
extends Node2D

@export var damage: float = 2.0
@export var beam_duration: float = 0.2
@export var max_length: float = 1200.0

@onready var ray_cast: RayCast2D = $RayCast2D
@onready var line: Line2D = $Line2D

var shooter: Node2D = null
var traits: Array[UpgradeData.WeaponType] = []
var hit_targets: Array[Node2D] = []

func _ready() -> void:
	_setup_raycast()
	_fire_beam()

func _setup_raycast() -> void:
	if not ray_cast: return
	
	ray_cast.target_position = Vector2.RIGHT * max_length
	ray_cast.collide_with_areas = true
	ray_cast.collide_with_bodies = true
	
	if shooter:
		ray_cast.add_exception(shooter)

func _fire_beam() -> void:
	var end_point = Vector2.RIGHT * max_length

	while ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		var hit_target: Node2D = null

		if collider:
			if collider.owner and collider.owner is AlienBase:
				hit_target = collider.owner
			elif collider is AlienBase or collider is Asteroid:
				hit_target = collider

		if is_instance_valid(hit_target) and not hit_targets.has(hit_target):
			hit_targets.append(hit_target)
			
			if hit_target.has_method("take_damage"):
				hit_target.take_damage(damage)
			elif hit_target.has_method("destroy"):
				hit_target.destroy()

			if traits.has(UpgradeData.WeaponType.ICE) and hit_target.has_method("apply_freeze"):
				hit_target.apply_freeze(2.0)

			if traits.has(UpgradeData.WeaponType.BOMB):
				_trigger_laser_explosion(hit_target.global_position)

		ray_cast.add_exception(collider)
		ray_cast.force_raycast_update()

	_draw_beam_visual(end_point)

func _trigger_laser_explosion(pos: Vector2) -> void:
	print("DEBUGLOG LaserBeam: BOMB Active! Ledakan Laser terjadi di ", pos)
	var enemies = get_tree().get_nodes_in_group("Alien")
	var explosion_radius = 80.0
	
	for enemy in enemies:
		if is_instance_valid(enemy) and pos.distance_to(enemy.global_position) <= explosion_radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage * 0.5)

func _draw_beam_visual(end_point: Vector2) -> void:
	if not line: return
	
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(end_point)

	var tween = create_tween()
	tween.tween_property(line, "modulate:a", 0.0, beam_duration)
	tween.tween_callback(queue_free)

func set_shooter(node: Node2D) -> void:
	shooter = node
