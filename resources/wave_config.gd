class_name WaveConfig
extends Resource

# Wave name
@export var wave_name: String = ""
# Wave ke berapa
@export var wave_number: int = 1
# Durasi wave nya
@export var duration_seconds: float = 30.0
# Spawn chance alien dari asteroid
@export var spawn_alien_chance: float = 0.20 
# Range (Min, Max) awal wave
@export var start_alien_interval: Vector2 = Vector2(2.7, 4.0) 
# Range (Min, Max) akhir wave
@export var end_alien_interval: Vector2 = Vector2(0.8, 1.2)
# Jumlah asteroid di awal wave
@export var initial_asteroids_count: int = 7     
# Range (Min, Max) awal wave
@export var start_asteroid_interval: Vector2 = Vector2(1.5, 2.5) 
# Range (Min, Max) akhir wave
@export var end_asteroid_interval: Vector2 = Vector2(0.5, 1.0) 
# List alien yang spawn  
@export var allowed_aliens: Array[AlienData] = [] 