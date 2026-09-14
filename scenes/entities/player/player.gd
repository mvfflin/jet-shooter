extends CharacterBody2D

@export_category("Stats")
@export var speed: int = 400

const BULLET = preload("res://scenes/entities/bullet/bullet.tscn")

@onready var muzzle: Marker2D = $Marker2D

var move_direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	movement_loop()
	look_at(get_global_mouse_position())
	
func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	move_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	var motion: Vector2 = move_direction.normalized() * speed
	set_velocity(motion)
	move_and_slide()

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("shoot"):
		#var bullet_instance = BULLET.instantiate()
		#get_tree().root.add_child(bullet_instance)
		#bullet_instance.global_position = muzzle.global_position
		#bullet_instance.rotation = rotation
