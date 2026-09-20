class_name ModularBullet
extends BulletBase

var traits: Array[UpgradeData.WeaponType] = []

@export var slow_factor: float = 0.5
@export var slow_duration: float = 2.0

@export var max_chains: int = 5
@export var chain_radius: float = 250.0
var current_chains: int = 0
var hit_targets: Array[Node2D] = []

@export var explosion_radius: float = 70.0

func _on_hit_target(target: Node2D) -> void:
	print("DEBUGLOG Bullet Hit: Menghantam target -> ", target.name, " | Traits aktif: ", traits)

	if not hit_targets.has(target):
		hit_targets.append(target)

	if target.has_method("take_damage"):
		print("DEBUGLOG Bullet Damage: Memberikan damage ", damage, " ke ", target.name)
		target.take_damage(damage)
	elif target is Asteroid and target.has_method("destroy"):
		print("DEBUGLOG Bullet Hit Asteroid: Mengancurkan Asteroid -> ", target.name)
		target.destroy()

	if traits.has(UpgradeData.WeaponType.ICE) and target is AlienBase:
		print("DEBUGLOG Bullet ICE: Memicu slow pada ", target.name)
		_apply_slow_effect(target)

	if traits.has(UpgradeData.WeaponType.BOMB):
		print("DEBUGLOG Bullet BOMB: Memicu ledakan AOE!")
		_explode()

	if traits.has(UpgradeData.WeaponType.CHAIN) and current_chains < max_chains:
		current_chains += 1
		print("DEBUGLOG Bullet CHAIN: Mencari target pantulan ke-", current_chains, "/", max_chains)
		
		var next_target = _find_next_target()

		if is_instance_valid(next_target):
			print("DEBUGLOG Bullet CHAIN Success: Target ditemukan -> ", next_target.name)
			global_position = target.global_position
			var new_dir = (next_target.global_position - global_position).normalized()
			set_direction(new_dir)
			
			timer = 0.0 
			return
		else:
			print("DEBUGLOG Bullet CHAIN Fail: Tidak ada target lain dalam radius ", chain_radius)

	print("DEBUGLOG Bullet Destroyed: Peluru di-queue_free()")
	queue_free()

func _apply_slow_effect(alien: AlienBase) -> void:
	if not is_instance_valid(alien): return
	
	print("DEBUGLOG ModularBullet: Memperlambat ", alien.name)
	alien.apply_slow(slow_factor, slow_duration)

func _explode() -> void:
	print("DEBUGLOG ModularBullet: Meledak di ", global_position)
	
	var query = PhysicsShapeQueryParameters2D.new()
	var circle = CircleShape2D.new()
	circle.radius = explosion_radius
	query.shape = circle
	query.transform = Transform2D(0, global_position)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results = get_world_2d().direct_space_state.intersect_shape(query)
	print("DEBUGLOG BOMB Check: Ditemukan ", results.size(), " collider di radius ledakan.")
	
	for res in results:
		var col = res.collider
		if col is AlienBase:
			print("DEBUGLOG BOMB Splash: Hit AlienBase -> ", col.name)
			col.take_damage(damage * 0.5) # Splash damage
		elif col.owner and col.owner is AlienBase:
			print("DEBUGLOG BOMB Splash: Hit AlienBase (via owner) -> ", col.owner.name)
			col.owner.take_damage(damage * 0.5)
		elif col is Asteroid and col.has_method("destroy"):
			print("DEBUGLOG BOMB Splash: Hit Asteroid -> ", col.name)
			col.destroy()

func _find_next_target() -> Node2D:
	var closest_enemy: Node2D = null
	var closest_distance: float = chain_radius

	# Ambil musuh dari grup Alien DAN grup Boss
	var enemies = get_tree().get_nodes_in_group("Alien") + get_tree().get_nodes_in_group("Boss")
	
	for enemy in enemies:
		if hit_targets.has(enemy) or not is_instance_valid(enemy):
			continue
			
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest_enemy = enemy

	return closest_enemy
    