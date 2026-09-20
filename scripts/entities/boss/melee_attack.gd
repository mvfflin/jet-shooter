extends State

@export var melee_damage: float = 3.0
@export var attack_range: float = 100.0 

func enter() -> void:
	super.enter()
	if animation_player:
		animation_player.play("Melee_attack")
	
	_deal_melee_damage()

func _deal_melee_damage() -> void:
	if not is_instance_valid(player):
		return
		
	var distance = owner.global_position.distance_to(player.global_position)
	if distance <= attack_range:
		if player.has_method("take_damage"):
			player.take_damage(melee_damage)
			print("DEBUGLOG MeleeAttack: Menyabet Player! Damage: ", melee_damage)

func transition() -> void:
	if owner.direction.length() > 100.0:
		get_parent().change_state("Follow")