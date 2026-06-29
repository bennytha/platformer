extends Node2D
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	player.set_camera_enabled(false)
	player.set_player_input_enabled(false)
