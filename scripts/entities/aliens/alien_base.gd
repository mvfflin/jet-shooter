# alien_base.gd -> Ngatur base behaviour nya dari alien
class_name AlienBase
extends CharacterBody2D

@export var data: AlienData
@export var xp_orb_scene: PackedScene = preload("res://scenes/entities/xporb/xporb.tscn")

var current_hp: float = 1.0
var player: Node2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox_area: Area2D = $HitboxArea

# Ukuran target visual sprite alien dalam pixel (disesuaikan dengan HitboxArea radius 11.0 => diameter 22px)
@export var target_sprite_size: float = 32.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	setup_visual()

func setup_visual() -> void:
	if not sprite:
		sprite = get_node_or_null("Sprite2D") as Sprite2D
		
	if data and sprite:
		current_hp = data.max_hp
		if data.texture:
			sprite.texture = data.texture
			
			# Auto scale sprite
			var tex_size = data.texture.get_size()
			if tex_size.x > 0 and tex_size.y > 0:
				var max_dim = max(tex_size.x, tex_size.y)
				var scale_factor = target_sprite_size / max_dim
				sprite.scale = Vector2(scale_factor, scale_factor)
				print("DEBUGLOG Alien Visual: Scaled sprite from ", tex_size, " with factor ", scale_factor)
		
		# Set warna 
		sprite.modulate = data.color if data.color != Color(0, 0, 0, 0) else Color.MAGENTA

func take_damage(amount: float) -> void:
	current_hp -= amount
	print("DEBUGLOG Alien: Menerima damage ", amount, " | Sisa HP: ", current_hp)
	if current_hp <= 0:
		die()

func die() -> void:
	print("DEBUGLOG Alien: Alien mati di posisi ", global_position)
	_spawn_xp_orb()
	queue_free()

func _spawn_xp_orb() -> void:
	if xp_orb_scene:
		var orb = xp_orb_scene.instantiate()
		orb.global_position = global_position
		get_parent().call_deferred("add_child", orb)
		print("DEBUGLOG XPOrb: Berhasil SPAWN XP Orb di posisi: ", global_position)
	else:
		print("ERROR XPOrb: xp_orb_scene pada AlienBase bernilai NULL!")
