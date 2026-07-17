extends Control

@export_file("*.tscn") var game_scene_path: String = "res://game/screens/game_conatiner/game_container.tscn"
@export_file("*.tscn") var level_selection_scene_path: String = "res://game/screens/level_selection/stage_select_menu.tscn"
const TEST_LEVEL_1 = preload("uid://dflw1w4xcitbe")

@onready var play: Button = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Play
@onready var levels: Button = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Levels
@onready var quit: Button = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Quit

func _ready() -> void:
	play.grab_focus()
func _on_play_pressed() -> void:
	EventBus.current_game = TEST_LEVEL_1
	SceneChanger.change_scene(game_scene_path)

func _on_levels_pressed() -> void:
	SceneChanger.change_scene(level_selection_scene_path)

func _on_quit_pressed() -> void:
	get_tree().quit()
