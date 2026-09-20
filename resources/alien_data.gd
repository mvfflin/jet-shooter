class_name AlienData
extends Resource

enum AlienType { 
    SKITTER, 
    OCULAR_DRONE, 
    SPAWNLING, 
    RING_WISP, 
    LEECH_SPORE 
}

# Tipe aliennya
@export var type: AlienType
# Nama
@export var name: String
# Max HP (Rencana pakek sistem hati maybe)
@export var max_hp: float = 1.0
# Speed initial
@export var speed: float = 100.0
# Texture
@export var texture: Texture2D
# Placeholder warna 
@export var color: Color = Color.WHITE 
# Ukuran sprite (dalam px)
@export var sprite_size: float = 32.0
# Radius collisionshape  
@export var hitbox_radius: float = 11.0 
# Jumlah exp yang didapatkan
@export var xp_value: int = 10
@export var death_shake_intensity: float = 4.0
@export var death_shake_duration: float = 0.1
@export var death_zoom_punch: float = 0.0
@export var death_particle_count: int = 12
@export var death_particle_color: Color = Color.LIME_GREEN
@export var death_particle_scale: float = 1.0