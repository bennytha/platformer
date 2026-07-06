# StageSelectMenu.gd
extends Control

# Drag your stage_button.tscn file into this slot in the Inspector
@export var button_template: PackedScene
@onready var grid_container: GridContainer = $MarginContainer/PanelContainer/VBoxContainer/GridContainer

func _ready():
	generate_stage_menu()

func generate_stage_menu():
	# Clear out any editor placeholder buttons if they exist
	for child in grid_container.get_children():
		child.queue_free()
		
	# Keep track of whether the previous level was completed to handle unlocking
	var previous_level_completed = true 
	
	# Loop through our sorted master list of levels
	for i in range(LevelManager.all_levels.size()):
		var current_level: LevelModel = LevelManager.all_levels[i]
		
		# Instantiate a new button
		var btn = button_template.instantiate()
		grid_container.add_child(btn)
		
		# Check progress from our save data manager
		var is_completed = LevelManager.is_level_completed(current_level.level_id)
		
		# Level 1 (index 0) is always unlocked. 
		# Otherwise, it's unlocked only if the previous level was beaten.
		var is_unlocked = (i == 0) or previous_level_completed
		
		# Configure the button
		btn.setup(current_level, is_unlocked, is_completed)
		
		# Connect the button's signal to our scene-changing logic
		btn.stage_selected.connect(_on_stage_button_selected)
		
		# Update our tracking variable for the next iteration of the loop
		previous_level_completed = is_completed

func _on_stage_button_selected(level_data: LevelModel):
	# Safely transition to the selected level scene
	EventBus.current_game = level_data
	EventBus.current_game_level_path  = level_data.scene_path
	SceneChanger.change_scene('res://common/scenes/game_container.tscn')
