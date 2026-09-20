extends State

@onready var pivot = owner.get_node_or_null("Pivot")
@onready var laser_area: Area2D = owner.get_node_or_null("Pivot/LaserArea")
@export var laser: AudioStream = preload("res://assets/sounds/sfx/laser.wav")

var can_transition: bool = false
@export var laser_damage: float = 2.0

func enter() -> void:
	super.enter()
	can_transition = false
	
	set_target()
	
	if laser_area:
		laser_area.monitoring = false
		laser_area.monitorable = false
	
	AudioManager.play_sfx(laser)
	
	await play_animation("Laser_cast")
	
	_trigger_laser_damage_with_delay()
	
	await play_animation("Laser")

	if laser_area:
		laser_area.monitoring = false
		laser_area.monitorable = false
		
	can_transition = true

func physics_update(_delta: float) -> void:
	pass

func set_target() -> void:
	if pivot and is_instance_valid(player):
		var aim_dir = (player.global_position - pivot.global_position).angle()
		pivot.rotation = aim_dir
		print("DEBUGLOG Laser: Target Dikunci di Arah Radian -> ", aim_dir)

# Biar damage muncul pas laser keluar & memastikan player masih ada di hitbox
func _trigger_laser_damage_with_delay() -> void:
	await get_tree().create_timer(1.0).timeout
	
	if laser_area:
		laser_area.monitoring = true
		laser_area.monitorable = true
		
		await get_tree().physics_frame
		await get_tree().physics_frame
		
		var is_player_inside: bool = false
		
		for body in laser_area.get_overlapping_bodies():
			if body.is_in_group("Player"):
				is_player_inside = true
				break
		
		if not is_player_inside:
			for area in laser_area.get_overlapping_areas():
				var parent_node = area.get_parent() if area.get_parent() else area.owner
				if (area.is_in_group("Player") or (parent_node and parent_node.is_in_group("Player"))):
					is_player_inside = true
					break
		
		if is_player_inside:
			_apply_laser_damage()
		else:
			print("DEBUGLOG Laser: Player berhasil menghindar/Hyperspace out!")

func exit() -> void:
	if laser_area:
		laser_area.monitoring = false
		laser_area.monitorable = false
		_debug_print_area_status("EXIT STATE (Area Dimatikan)")

func play_animation(anim_name: String) -> void:
	if animation_player:
		animation_player.play(anim_name)
		await animation_player.animation_finished

func _apply_laser_damage() -> void:
	if not is_instance_valid(player):
		print("DEBUGLOG Laser Error: Player instance tidak valid!")
		return
		
	if not laser_area:
		print("DEBUGLOG Laser Error: Node Pivot/LaserArea TIDAK DITEMUKAN!")
		return
		
	var overlapping_bodies = laser_area.get_overlapping_bodies()
	var overlapping_areas = laser_area.get_overlapping_areas()
	
	print("DEBUGLOG Laser Damage Check:")
	print("  -> Overlapping Bodies : ", overlapping_bodies)
	print("  -> Overlapping Areas  : ", overlapping_areas)
	
	for body in overlapping_bodies:
		if body.is_in_group("Player") and body.has_method("take_damage"):
			body.take_damage(laser_damage)
			print("DEBUGLOG Laser HIT: Body Player terdeteksi dan terkena damage!")
			return
			
	for area in overlapping_areas:
		var target = area.get_parent() if area.get_parent() else area.owner
		if target and target.is_in_group("Player") and target.has_method("take_damage"):
			target.take_damage(laser_damage)
			print("DEBUGLOG Laser HIT: HitboxArea Player terdeteksi dan terkena damage!")
			return

func transition() -> void:
	if can_transition:
		can_transition = false
		get_parent().change_state("Dash")

func _debug_print_area_status(step_name: String) -> void:
	if not laser_area:
		print("DEBUGLOG Laser Debug [", step_name, "]: LaserArea = NULL")
		return
		
	print("DEBUGLOG Laser Debug [", step_name, "]:")
	print("  * monitoring  = ", laser_area.monitoring)
	print("  * monitorable = ", laser_area.monitorable)
	print("  * mask        = ", laser_area.collision_mask)
	print("  * layer       = ", laser_area.collision_layer)