extends Node2D

@onready var player = $Player

func _ready() -> void:
	# Listen for the exact moment the player is done falling off screen
	player.player_respawn_ready.connect(_on_player_respawn_ready)

func _on_player_respawn_ready() -> void:
	# Clean up the old player instance and reload the level
	player.queue_free()
	get_tree().reload_current_scene()
