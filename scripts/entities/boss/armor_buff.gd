extends State

var can_transition: bool = false

func enter() -> void:
	super.enter()
	if animation_player:
		animation_player.play("Armor_buff")
	
	if owner:
		owner.DEF = 1
	
	if animation_player:
		await animation_player.animation_finished
		
	if owner:
		owner.DEF = 0 
		
	can_transition = true
	
func transition() -> void:
	if can_transition:
		can_transition = false
		get_parent().change_state("Follow")