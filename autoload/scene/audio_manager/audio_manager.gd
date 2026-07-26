extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var global_sfx_player: AudioStreamPlayer = $GlobalSFXPlayer
@onready var ui_player: AudioStreamPlayer = $UIPlayer

# Play background music with basic crossfade or restart guard
func play_music(stream: AudioStream) -> void:
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stream = stream
	music_player.play()

# Play one-off non-positional sounds (UI focus, Win screen, Death)
func play_sfx(stream: AudioStream, pitch_scale: float = 1.0) -> void:
	if stream == null:
		return
	global_sfx_player.stream = stream
	global_sfx_player.pitch_scale = pitch_scale
	global_sfx_player.play()

func play_ui_sfx(stream: AudioStream, pitch_scale: float = 1.0) -> void:
	if stream == null:
		return
	ui_player.stream = stream
	ui_player.pitch_scale = pitch_scale
	ui_player.play()
