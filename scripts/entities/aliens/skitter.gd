# skitter.gd -> Ngatur behaviour alien skitter 
extends AlienBase

func _ready() -> void:
	# Ngambil ready dari parent
	super._ready() 
	
	if not hitbox_area:
		hitbox_area = get_node_or_null("HitboxArea") as Area2D
	
	# Jika dia menabrak player maka menjalankan _on_swarmer_hit_body
	if hitbox_area:
		hitbox_area.body_entered.connect(_on_swarmer_hit_body)
		hitbox_area.area_entered.connect(_on_swarmer_hit_area)

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player): 
		return
	
	# Behaviour khusus Skitter
	var move_speed = data.speed if data else 180.0
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * move_speed
	rotation = dir.angle()
	move_and_slide()

# Kalau hit player deal damage
func _on_swarmer_hit_body(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_deal_contact_damage(body)

# Kalau masuk ke area player deal damage
func _on_swarmer_hit_area(area: Area2D) -> void:
	if area.owner and area.owner.is_in_group("Player"):
		_deal_contact_damage(area.owner)

# Deal damage
func _deal_contact_damage(target_player: Node2D) -> void:
	var damage_amount = data.damage if data and "damage" in data else 1.0
	print("DEBUGLOG Skitter: Menabrak Player! Memberikan damage: ", damage_amount)
	target_player.take_damage(damage_amount)
	die()