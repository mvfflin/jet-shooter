class_name XPOrb
extends Area2D

@export var xp_amount: int = 2
@export var move_speed: float = 300.0
@export var magnet_radius: float = 120.0

var player: Node2D = null
var is_collecting: float = false

func _ready() -> void:
	print("DEBUGLOG XPOrb: _ready() dipanggil di posisi ", global_position)
	player = get_tree().get_first_node_in_group("Player")
	
	# Connect signal ketika player masuk ke area magnet/orb
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
		
	var dist = global_position.distance_to(player.global_position)
	
	# Fitur magnet XP: Menyedot ke arah player jika sudah dekat
	if dist <= magnet_radius:
		var dir = (player.global_position - global_position).normalized()
		global_position += dir * move_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_collect()

func _on_area_entered(area: Area2D) -> void:
	# Cek jika HitboxArea milik Player yang menyentuh Orb
	if area.owner and area.owner.is_in_group("Player"):
		_collect()

func _collect() -> void:
	if is_collecting: return
	is_collecting = true
	
	print("DEBUGLOG XPOrb: TERAMBIL oleh Player! Memberikan XP: ", xp_amount)
	
	# Tambahkan XP ke DataManager
	if DataManager and DataManager.has_method("add_xp"):
		DataManager.add_xp(xp_amount)
	elif DataManager and "xp" in DataManager:
		DataManager.xp += xp_amount
		print("DEBUGLOG DataManager: XP Sekarang = ", DataManager.xp)
	else:
		print("WARNING XPOrb: DataManager tidak memiliki metode/properti XP!")
		
	queue_free()