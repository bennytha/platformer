extends Node2D
@onready var player: CharacterBody2D = $Player

const DISCORD_URL:String = 'https://discord.gg/44PNjJsJM'

func _ready() -> void:
	player.set_camera_enabled(false)
	player.set_player_input_enabled(false)


func _on_discord_pressed() -> void:
	var error = OS.shell_open(DISCORD_URL)
	if error != OK:
		push_error("Failed to open URL: ", error)
