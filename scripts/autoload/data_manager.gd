extends Node

# Signal UI & Event
signal hp_changed(current_hp: float, max_hp: float)
signal xp_changed(current_xp: int, xp_to_next: int)
signal level_up(new_level: int)
signal energy_changed(current_energy: float, max_energy: float)
signal hyperspace_ready()

# Player Base Stats
var max_hp: float = 5.0
var current_hp: float = 5.0

var attack_damage: float = 2.0
var fire_rate: float = 0.5
var move_speed: float = 300.0
var magnet_radius: float = 120.0

# Hyperspace stats
var max_energy: float = 100.0
var current_energy: float = 0.0
var energy_per_xp: float = 10.0 
var passive_energy_rate: float = 20.0 

# Progression Stats
var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 10
var waves_survived: int = 0

# Multi-Weapon Trait System & Progression Tracking
var active_weapon_traits: Array[UpgradeData.WeaponType] = []
var acquired_upgrades: Array[UpgradeData] = []

func _ready() -> void:
	reset_data()

func reset_data() -> void:
	print("DEBUGLOG DataManager: Memulihkan statistik game ke kondisi awal...")
	
	current_level = 1
	current_xp = 0
	xp_to_next_level = 100
	waves_survived = 0
	
	max_hp = 5.0
	current_hp = max_hp
	
	attack_damage = 2.0
	fire_rate = 0.5
	move_speed = 300.0
	magnet_radius = 120.0
	
	active_weapon_traits.clear()
	acquired_upgrades.clear()
	
	hp_changed.emit(current_hp, max_hp)
	xp_changed.emit(current_xp, xp_to_next_level)

	max_energy = 100.0
	current_energy = 0.0
	energy_per_xp = 10.0
	passive_energy_rate = 20.0
	energy_changed.emit(current_energy, max_energy)

func add_weapon_trait(type: UpgradeData.WeaponType) -> void:
	if not active_weapon_traits.has(type):
		active_weapon_traits.append(type)
		print("DEBUGLOG DataManager: Trait Senjata Ditambahkan -> ", type)

func apply_upgrade(upgrade: UpgradeData) -> void:
	if not upgrade: return
	
	if not acquired_upgrades.has(upgrade):
		acquired_upgrades.append(upgrade)
		
	match upgrade.category:
		UpgradeData.UpgradeCategory.STAT_BUFF:
			_apply_stat_buff(upgrade.stat_name, upgrade.stat_value)
		UpgradeData.UpgradeCategory.WEAPON_UNLOCK:
			add_weapon_trait(upgrade.weapon_type)

func _apply_stat_buff(stat_name: String, value: float) -> void:
	match stat_name.to_lower():
		"damage":
			attack_damage += value
		"fire_rate":
			fire_rate += value
		"move_speed":
			move_speed += value
		"max_hp":
			max_hp += value
			current_hp += value
			hp_changed.emit(current_hp, max_hp)
		"magnet":
			magnet_radius += value

func add_xp(amount: int) -> void:
	add_energy(amount * energy_per_xp)

	current_xp += amount
	print("DEBUGLOG DataManager: Tambah XP +", amount, " | Total: ", current_xp, "/", xp_to_next_level)
	
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		current_level += 1
		xp_to_next_level = int(xp_to_next_level * 1.2)
		
		print("DEBUGLOG DataManager: LEVEL UP! Sekarang Level ", current_level)
		level_up.emit(current_level)
		
	xp_changed.emit(current_xp, xp_to_next_level)

func add_hp(amount: int) -> void:
	if current_hp >= max_hp:
		return

	current_hp = min(current_hp + amount, max_hp)
	print("DEBUGLOG DataManager: Tambah HP +", amount, " | Total: ", current_hp, "/", xp_to_next_level)
		
	hp_changed.emit(current_hp, max_hp)

func add_energy(amount: float) -> void:
	if current_energy >= max_energy: return
	
	current_energy = min(max_energy, current_energy + amount)
	energy_changed.emit(current_energy, max_energy)
	
	if current_energy >= max_energy:
		print("DEBUGLOG DataManager: Hyperspace Skill READY!")
		hyperspace_ready.emit()

func consume_hyperspace_energy() -> bool:
	if current_energy >= max_energy:
		current_energy = 0.0
		energy_changed.emit(current_energy, max_energy)
		return true
	return false