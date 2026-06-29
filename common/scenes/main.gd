extends Node2D

func _ready() -> void:
	# Main listens to the global bus 24/7
	EventBus.player_died.connect(_on_player_died)

func _on_player_died() -> void:
	print("Main received death signal! Showing Game Over screen...")
	# Show your game over menu UI here
