class_name BossEnemy
extends CharacterBody2D

signal boss_defeated

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var sprite: Sprite2D = $Sprite2D
@onready var progress_bar: ProgressBar = $UI/ProgressBar
@onready var laser_area: Area2D = $Pivot/LaserArea

var direction: Vector2 = Vector2.ZERO
var DEF: int = 0

var health: float = 100.0:
	set(value):
		health = value
		if progress_bar:
			progress_bar.value = health
		
		if health <= progress_bar.max_value / 4.0 and DEF == 0:
			print("DEBUGLOG Boss: HP kritis, mentrigger ArmorBuff!")
			var fsm = get_node_or_null("FiniteStateMachine")
			if fsm and fsm.has_method("change_state"):
				fsm.change_state("ArmorBuff")
		
		elif health <= 0:
			print("DEBUGLOG Boss: HP habis, mentrigger Death!")
			if progress_bar:
				progress_bar.visible = false
			var fsm = get_node_or_null("FiniteStateMachine")
			if fsm and fsm.has_method("change_state"):
				fsm.change_state("Death")

func _ready() -> void:
	add_to_group("Alien")
	add_to_group("Boss")
	print("DEBUGLOG Boss: Boss berhasil di-spawn di posisi -> ", global_position)
	
	scale = Vector2(2.5, 2.5)
	
	if progress_bar:
		progress_bar.max_value = health
		progress_bar.value = health
		progress_bar.visible = true
		
	var anim = get_node_or_null("AnimationPlayer")
	if anim:
		anim.play("Idle")
	
	if laser_area:
		laser_area.monitoring = false

func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player")
		return
		
	direction = player.global_position - global_position
	if sprite:
		sprite.flip_h = direction.x < 0

func _physics_process(_delta: float) -> void:
	velocity = direction.normalized() * 75.0
	move_and_slide()

func take_damage(damage: float) -> void:
	var net_damage = max(1.0, damage - DEF)
	health -= net_damage
	print("DEBUGLOG Boss: TERKENA DAMAGE! Masuk: ", damage, " | Net: ", net_damage, " | Sisa HP: ", health)
	
	if JuiceManager:
		JuiceManager.shake_camera(3.0, 0.1)

func _on_boss_slain_complete() -> void:
	print("DEBUGLOG Boss: Animasi death selesai, menghapus boss dari scene.")
	boss_defeated.emit()
	queue_free()
