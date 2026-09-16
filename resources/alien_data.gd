class_name AlienData
extends Resource

enum AlienType { SKITTER, OCULAR_DRONE, SPAWNLING, RING_WISP, LEECH_SPORE }

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