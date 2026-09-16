class_name UpgradeData
extends Resource

enum UpgradeType { 
	FIRE_RATE, 
	DAMAGE, 
	EXTRA_FRAGMENT, 
	SPEED, 
	MAGNET_RADIUS, 
	EXTRA_PROJECTILE 
	}

@export var id: UpgradeType
@export var title: String
@export var description: String
@export var icon: Texture2D
@export var value_modifier: float = 1.0