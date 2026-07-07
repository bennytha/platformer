extends Control

@export_file("*.tscn") var game_scene_path: String = "res://common/scenes/game_container.tscn"
@export_file("*.tscn") var level_selection_scene_path: String = "res://game/screens/level_selection/stage_select_menu.tscn"
const TEST_LEVEL_1 = preload("uid://dflw1w4xcitbe")

func _on_play_pressed() -> void:
	EventBus.current_game = TEST_LEVEL_1
	#SceneChanger.change_scene(game_scene_path)
	SceneChanger.change_scene('res://common/scenes/game_container.tscn')

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_levels_pressed() -> void:
	SceneChanger.change_scene(level_selection_scene_path)
	
