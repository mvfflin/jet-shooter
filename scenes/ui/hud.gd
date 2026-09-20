class_name HUD
extends Control

@export var segment_full_tex: Texture2D   
@export var segment_empty_tex: Texture2D 

@onready var hp_container: HBoxContainer = $PlayerStatsPanel/HPContainer
@onready var energy_bar: TextureProgressBar = $PlayerStatsPanel/EnergyBar

func _ready() -> void:
	print("DEBUGLOG HUD: _ready dipanggil.")
	
	if DataManager:
		print("DEBUGLOG HUD: DataManager terdeteksi, menghubungkan sinyal...")
		
		# Connect HP
		DataManager.hp_changed.connect(_on_hp_changed)
		_on_hp_changed(DataManager.current_hp, DataManager.max_hp)
		
		# Connect energy
		DataManager.energy_changed.connect(_on_energy_changed)
		_on_energy_changed(DataManager.current_energy, DataManager.max_energy)
	else:
		print("ERROR HUD: DataManager tidak ditemukan (Autoload null)!")

# Callback HP berubah
func _on_hp_changed(cur: float, max_val: float) -> void:
	print("DEBUGLOG HUD: _on_hp_changed -> HP:", cur, "/", max_val)
	
	if not hp_container:
		return

	# Clear old container
	for child in hp_container.get_children():
		child.queue_free()
		
	var max_hp_int: int = int(max_val)
	var current_hp_int: int = int(cur)
	
	for i in range(max_hp_int):
		var seg = TextureRect.new()
		seg.custom_minimum_size = Vector2(32, 32)
		
		seg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		seg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		if i < current_hp_int:
			seg.texture = segment_full_tex
		else:
			seg.texture = segment_empty_tex
			
		hp_container.add_child(seg)

# Callback saat Energy berubah
func _on_energy_changed(current: float, max_val: float) -> void:
	print("DEBUGLOG HUD: _on_energy_changed -> Energy:", current, "/", max_val)
	
	if not energy_bar:
		print("ERROR HUD: energy_bar NULL!")
		return
		
	energy_bar.max_value = max_val
	energy_bar.value = current
