extends State

@onready var boss = $"../.."
var can_transition : bool = false

func enter():
	super.enter()
	animation_player.play("Armor_buff")
	boss.DEF = 8
	await animation_player.animation_finished
	boss.DEF = 5
	can_transition = true
	
func transition():
	if can_transition:
		can_transition = false
		get_parent().change_state("Follow")
