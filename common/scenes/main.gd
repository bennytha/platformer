extends Node2D
@onready var level_container: Node = $LevelContainer

func _ready() -> void:
	# Main listens to the global bus 24/7
	EventBus.player_died.connect(_on_player_died)
	SceneChanger.register_level_container(level_container)

func _on_player_died() -> void:
	print("Main received death signal! Showing Game Over screen...")
	# Show your game over menu UI here
	SceneChanger.switch_level("res://common/scenes/game_over/game_over.tscn")
