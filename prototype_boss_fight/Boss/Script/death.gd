extends State

func enter():
	super.enter()
	animation_player.play("Death")
	await animation_player.animation_finished
	animation_player.play("Boss_slained")
