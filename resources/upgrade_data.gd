class_name UpgradeData
extends Resource

# Kategori upgrade
enum UpgradeCategory {
	STAT_BUFF,     
	WEAPON_UNLOCK  
}

# Tipe senjata
enum WeaponType {
	NONE,
	SPREAD,    # Tembakan menyebar (3-5 peluru)
	ICE,       # Peluru es (memberi efek slow)
	CHAIN,     # Peluru memantul antar musuh
	BOMB,      # Peluru meledak (AOE Damage)
	LASER      # Peluru laser menembus lurus (Piercing)
}

@export_group("Visual & Info")
@export var id: String = "upgrade_id"
@export var title: String = "Nama Upgrade"
@export_multiline var description: String = "Penjelasan singkat efek upgrade ini untuk ditampilkan di kartu UI."
@export var icon: Texture2D

@export_group("Upgrade Category")
@export var category: UpgradeCategory = UpgradeCategory.STAT_BUFF

@export_group("Stat Buff Settings")
# Nama variabel stat yang diubah di DataManager (misal: "attack_damage", "fire_rate", "move_speed", "magnet_radius", "extra_fragments")
@export var stat_name: String = ""
# Nilai penambahan stat (bisa positif untuk buff, atau negatif jika interval fire_rate dipercepat)
@export var stat_value: float = 0.0

@export_group("Weapon Unlock Settings")
# Tipe senjata yang diaktifkan jika kategori adalah WEAPON_UNLOCK
@export var weapon_type: WeaponType = WeaponType.NONE