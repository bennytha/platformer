extends Control

@export_file("*.tscn") var start_screen_path: String = "res://game/screens/start_screen/start_screen.tscn"
@export_file("*.tscn") var levels_screen_path: String = "res://game/screens/level_selection/stage_select_menu.tscn"
@export_file("*.tscn") var game_container_path: String = "res://game/screens/game_conatiner/game_container.tscn"

@onready var close: Button = $PanelContainer/VBoxContainer/HBoxContainer2/Close

var local_bus: GameContainer

func _ready() -> void:
	local_bus = UtilsFuncs.find_local_bus(self)
	visibility_changed.connect(_on_visibility_changed)
	if is_visible_in_tree():
		close.grab_focus()

func _on_close_pressed() -> void:
	if local_bus:
		local_bus.show_menu.emit(false)
	else:
		print('local bus not found')

func _on_visibility_changed() -> void:
	# Only grab focus when the menu actually becomes visible in the tree
	if is_visible_in_tree():
		# Using call_deferred ensures Godot sets focus after the UI layout updates
		close.grab_focus.call_deferred()

func _on_home_pressed() -> void:
	SceneChanger.change_scene(start_screen_path)


func _on_levels_pressed() -> void:
	SceneChanger.change_scene(levels_screen_path)


func _on_retry_pressed() -> void:
	SceneChanger.change_scene(game_container_path)
