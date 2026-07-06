extends Control

@export_file("*.tscn") var game_scene_path: String = "res://common/scenes/game_container.tscn"
@export_file("*.tscn") var level_selection_scene_path: String = "res://game/screens/level_selection/stage_select_menu.tscn"

func _on_play_pressed() -> void:
	SceneChanger.change_scene(game_scene_path)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_levels_pressed() -> void:
	SceneChanger.change_scene(level_selection_scene_path)
	
