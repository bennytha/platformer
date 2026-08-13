extends Control

@export_file("*.tscn") var game_scene_path: String = "res://game/screens/game_conatiner/game_container.tscn"
@export_file("*.tscn") var start_scene_path: String = "res://game/screens/start_screen/start_screen.tscn"
@export var button_template: PackedScene
@onready var grid_container: GridContainer = $MarginContainer/PanelContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var scroll_container: ScrollContainer = $MarginContainer/PanelContainer/VBoxContainer/ScrollContainer

func _ready():
	generate_stage_menu()

func generate_stage_menu():
	# Clear out any editor placeholder buttons if they exist
	for child in grid_container.get_children():
		child.queue_free()
		
	# Keep track of whether the previous level was completed to handle unlocking
	var previous_level_completed = true 
	var last_button: Button = null
	var last_uncompleted_button: Button = null
	
	# Loop through our sorted master list of levels
	for i in range(LevelManager.all_levels.size()):
		var current_level: LevelModel = LevelManager.all_levels[i]
		
		# Instantiate a new button
		var btn = button_template.instantiate()
		grid_container.add_child(btn)
		last_button = btn
		
		# Check progress from our save data manager
		var is_completed = LevelManager.is_level_completed(current_level.level_id)
		
		# Level 1 (index 0) is always unlocked. 
		# Otherwise, it's unlocked only if the previous level was beaten.
		var is_unlocked = (i == 0) or previous_level_completed
		
		var meta_data: Dictionary = LevelManager.get_meta_data(current_level.level_id)
		
		var highscore := 0
		if meta_data.has("total"):
			highscore = int(meta_data.get("total", 0))
		# Configure the button
		btn.setup(current_level, is_unlocked, is_completed, highscore)
		
		# Connect the button's signal to our scene-changing logic
		btn.stage_selected.connect(_on_stage_button_selected)
		
		if is_unlocked and not is_completed:
			last_uncompleted_button = btn
		
		# Update our tracking variable for the next iteration of the loop
		previous_level_completed = is_completed
	
	focus_stage_button(last_button, last_uncompleted_button)

func focus_stage_button(last_button: Button, last_uncompleted_button: Button):
	if grid_container.get_child_count() == 0:
		return

	var focus_button: Button = null
	if last_uncompleted_button != null:
		focus_button = last_uncompleted_button
	elif last_button != null:
		focus_button = last_button

	if focus_button != null:
		focus_button.grab_focus()
		# Wait for Godot to finalize layout dimensions and container bounds
		await get_tree().process_frame
		scroll_container.ensure_control_visible(focus_button)
		

func _on_stage_button_selected(level_data: LevelModel):
	# Safely transition to the selected level scene
	EventBus.current_game = level_data
	SceneChanger.change_scene(game_scene_path)


func _on_back_pressed() -> void:
	SceneChanger.change_scene(start_scene_path)
