extends Area2D


@onready var animated_sprite = $AnimatedSprite2D
@onready var player = get_parent().find_child("player")
@onready var progress_bar = $ProgressBar

var acceleration: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var health = 20:
	set(value):
		health = value
		progress_bar.value = value
		if value <= 0:
			progress_bar.visible = false
			queue_free()

func _physics_process(delta):
	acceleration = (player.position - position).normalized() * 700
	
	velocity += acceleration * delta
	rotation = velocity.angle()
	
	velocity = velocity.limit_length(150)
	
	position += velocity * delta

func take_damage(amount: int):
	health -= amount


func _on_body_entered(body):
	body.take_damage(2.5)
	queue_free()
