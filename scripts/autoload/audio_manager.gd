extends Node

# Audio Player
var bgm_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	bgm_player = AudioStreamPlayer.new()
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	bgm_player.bus = "Music"
	add_child(bgm_player)

# Play BGM
func play_bgm(stream: AudioStream, target_volume_db: float = 0.0, fade_duration: float = 1.0) -> void:
	if bgm_player.stream == stream and bgm_player.playing:
		return

	# Setting stream     
	bgm_player.stream = stream
	# Fade in effect
	bgm_player.volume_db = -80.0 
	bgm_player.play()
	
	# Tween up volume 
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(bgm_player, "volume_db", target_volume_db, fade_duration)

func stop_bgm(fade_duration: float = 1.0) -> void:
	if not bgm_player.playing:
		return
		
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(bgm_player, "volume_db", -80.0, fade_duration)
	await tween.finished
	
	bgm_player.stop()
	bgm_player.volume_db = 0.0 

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return
		
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS 
	sfx_player.stream = stream
	sfx_player.bus = "SFX"
	sfx_player.volume_db = volume_db
	add_child(sfx_player)
	
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)