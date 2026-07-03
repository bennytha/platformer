extends Node2D
class_name GameContainer

@onready var level_container: Node = $LevelContainer

signal show_bag(show:bool)

var is_bag_shown := false

func _ready() -> void:
	# Main listens to the global bus 24/7
	EventBus.player_died.connect(_on_player_died)
	SceneChanger.register_level_container(level_container)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("bag"):
		is_bag_shown = !is_bag_shown
		show_bag.emit(is_bag_shown)

func _on_player_died() -> void:
	print("Main received death signal! Showing Game Over screen...")
	# Show your game over menu UI here
	SceneChanger.switch_level("res://common/scenes/game_over/game_over.tscn")
