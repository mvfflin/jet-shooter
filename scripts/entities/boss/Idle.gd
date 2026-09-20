extends State

var player_entered: bool = false

func enter() -> void:
	super.enter()
	player_entered = false

func transition() -> void:
	if player_entered:
		get_parent().change_state("Follow")

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_entered = true