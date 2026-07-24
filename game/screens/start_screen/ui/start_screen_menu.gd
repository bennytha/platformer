extends Control

@export_file("*.tscn") var game_scene_path: String = "res://game/screens/game_conatiner/game_container.tscn"
@export_file("*.tscn") var level_selection_scene_path: String = "res://game/screens/level_selection/stage_select_menu.tscn"
const TEST_LEVEL = preload("uid://ds2xa3fyryfdy")

@onready var play: Button = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Play

var current_game_status={}

func _ready() -> void:
	current_game_status = LevelManager.get_game_start_info()
	play.text = current_game_status.label
	play.grab_focus()
	print(LevelManager.is_new_game())
	
func _on_test_level_pressed() -> void:
	EventBus.current_game = TEST_LEVEL
	SceneChanger.change_scene(game_scene_path)

func _on_play_pressed() -> void:
	EventBus.current_game = current_game_status.level
	SceneChanger.change_scene(game_scene_path)

func _on_levels_pressed() -> void:
	SceneChanger.change_scene(level_selection_scene_path)

func _on_options_pressed() -> void:
	LevelManager.reset_game()

func _on_quit_pressed() -> void:
	get_tree().quit()
