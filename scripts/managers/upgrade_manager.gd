class_name UpgradeManager
extends Node

@export var upgrade_pool: Array[UpgradeData] = []
@export var upgrade_screen_scene: PackedScene = preload("res://scenes/ui/upgrade_scene.tscn")
@export var level_up_label: Label

func _ready() -> void:
	add_to_group("UpgradeManager")
	if DataManager:
		DataManager.level_up.connect(_on_level_up)

func _on_level_up(new_level: int) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if not is_instance_valid(player):
		print("DEBUGLOG UpgradeManager: Player sudah mati, membatalkan UI Level Up.")
		return

	print("DEBUGLOG UpgradeManager: Pemicu Level Up! Menampilkan Pop-Up...")

	if upgrade_pool.is_empty():
		return

	var available_pool: Array[UpgradeData] = []
	for upg in upgrade_pool:
		if DataManager and not DataManager.acquired_upgrades.has(upg):
			available_pool.append(upg)

	if available_pool.is_empty():
		print("DEBUGLOG UpgradeManager: Semua upgrade sudah didapatkan!")
		return

	var selected_upgrades: Array[UpgradeData] = []
	available_pool.shuffle()
	var count = min(3, available_pool.size())
	for i in range(count):
		selected_upgrades.append(available_pool[i])

	_show_level_up_popup(func():
		if not is_instance_valid(player): return
		
		get_tree().paused = true
		if upgrade_screen_scene:
			var ui = upgrade_screen_scene.instantiate() as UpgradeScreen
			get_tree().root.add_child(ui)
			ui.setup_cards(selected_upgrades)
	)

func _show_level_up_popup(on_complete_callback: Callable) -> void:
	var player = get_tree().get_first_node_in_group("Player") as Node2D
	if not is_instance_valid(player):
		on_complete_callback.call()
		return

	var popup_label = level_up_label
	var temp_canvas: CanvasLayer = null

	if not popup_label:
		temp_canvas = CanvasLayer.new()
		temp_canvas.process_mode = Node.PROCESS_MODE_ALWAYS
		temp_canvas.layer = 10
		get_tree().root.add_child(temp_canvas)

		popup_label = Label.new()
		temp_canvas.add_child(popup_label)

	popup_label.text = "LEVEL UP!"
	popup_label.visible = true
	popup_label.add_theme_font_size_override("font_size", 28)
	popup_label.add_theme_color_override("font_color", Color.YELLOW)
	popup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	popup_label.reset_size()
	popup_label.pivot_offset = popup_label.size / 2.0

	var spawn_pos = player.global_position + Vector2(-popup_label.size.x / 2.0, -50.0)
	popup_label.global_position = spawn_pos
	popup_label.scale = Vector2.ZERO
	popup_label.modulate.a = 1.0

	var target_y = spawn_pos.y - 40.0
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	tween.tween_property(popup_label, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(popup_label, "scale", Vector2(1.0, 1.0), 0.1)

	tween.parallel().tween_property(popup_label, "global_position:y", target_y, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(popup_label, "modulate:a", 0.0, 0.4).set_delay(0.2)

	var finish_popup := func() -> void:
		if temp_canvas and is_instance_valid(temp_canvas):
			temp_canvas.queue_free()
		elif popup_label:
			popup_label.visible = false
		on_complete_callback.call()
	tween.tween_callback(finish_popup)