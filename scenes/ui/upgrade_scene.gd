class_name UpgradeScreen
extends CanvasLayer

@export var card_scene: PackedScene = preload("res://scenes/ui/upgrade_card.tscn")
@onready var card_container: HBoxContainer = $ColorRect/CenterContainer/CardContainer
@onready var banner_label: Label = $ColorRect/BannerLabel 

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func setup_cards(upgrades: Array[UpgradeData]) -> void:
	for child in card_container.get_children():
		child.queue_free()

	if banner_label:
		banner_label.text = "UPGRADE UNLOCKED!"
		banner_label.scale = Vector2.ZERO
		banner_label.pivot_offset = banner_label.size / 2.0
		var tween_banner = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween_banner.tween_property(banner_label, "scale", Vector2(1.2, 1.2), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween_banner.tween_property(banner_label, "scale", Vector2(1.0, 1.0), 0.1)

	for i in range(upgrades.size()):
		var upgrade = upgrades[i]
		var card = card_scene.instantiate() as UpgradeCard
		card_container.add_child(card)
		card.setup(upgrade)
		card.card_selected.connect(_on_card_selected)

		var original_pos = card.position
		card.position.y += 400.0 
		card.modulate.a = 0.0    
		
		var tween_card = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween_card.tween_interval(i * 0.1) 
		tween_card.tween_property(card, "position:y", original_pos.y, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween_card.parallel().tween_property(card, "modulate:a", 1.0, 0.3)

func _on_card_selected(selected_upgrade: UpgradeData) -> void:
	if DataManager:
		DataManager.apply_upgrade(selected_upgrade)
	
	get_tree().paused = false
	queue_free()