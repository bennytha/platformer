extends Node

# A helper function to change scenes safely
func change_scene(target_scene_path: String) -> void:
	# Deferred call ensures the current scene finishes its frame processing
	get_tree().call_deferred("change_scene_to_file", target_scene_path)
