extends Control

@export_file("*.tscn") var game_scene_path: String = "res://game/levels/level.tscn"

func _on_play_pressed() -> void:
	SceneChanger.change_scene(game_scene_path)


func _on_quit_pressed() -> void:
	get_tree().quit()
