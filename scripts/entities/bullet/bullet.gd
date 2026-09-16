class_name Bullet
extends Area2D

const SPEED = 600.0
var direction = Vector2.ZERO
var damage = 1.0
var shooter_node: Node2D = null

func _ready() -> void:
	# Connect ke dignal on_body_entered dan area
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	# Arah tembakan
	position += direction * SPEED * delta

# Set direksi
func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	rotation = direction.angle()

func set_shooter(shooter: Node2D) -> void:
	shooter_node = shooter

# Logic saat menabrak Object Solid (kayak Alien / Player)
func _on_body_entered(body: Node2D) -> void:
	# Jangan ngasih damage ke penembak sendiri
	if body == shooter_node: return
	
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()

# Logic saat menabrak Area2D lain (kayak Asteroid)
func _on_area_entered(area: Area2D) -> void:
	if area == shooter_node: return
	
	if area.has_method("destroy"): # Khusus Asteroid
		area.destroy()
		queue_free()
	elif area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()