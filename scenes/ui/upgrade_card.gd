class_name UpgradeCard
extends PanelContainer

signal card_selected(upgrade: UpgradeData)

@onready var icon_rect: TextureRect = $MarginContainer/VBoxContainer/TextureRect
@onready var title_label: Label = $MarginContainer/VBoxContainer/Title
@onready var desc_label: Label = $MarginContainer/VBoxContainer/Description

var current_upgrade: UpgradeData

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func setup(upgrade: UpgradeData) -> void:
	current_upgrade = upgrade
	print("DEBUGLOG UpgradeCard: Setting up card -> Title: ", upgrade.title)
	
	if title_label: title_label.text = upgrade.title
	if desc_label: desc_label.text = upgrade.description
	if icon_rect and upgrade.icon: icon_rect.texture = upgrade.icon

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("DEBUGLOG UpgradeCard: Klik terdeteksi pada kartu -> ", current_upgrade.title)
		card_selected.emit(current_upgrade)