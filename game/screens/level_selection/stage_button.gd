extends Button

var level_data: LevelModel
var is_unlocked: bool = false
var is_completed: bool = false

signal stage_selected(level_data: LevelModel)

func setup(data: LevelModel, is_unlocked_flag: bool, is_completed_flag: bool):
	level_data = data
	is_unlocked = is_unlocked_flag
	is_completed = is_completed_flag
	text = data.level_name
	
	# Visual feedback based on save state
	disabled = not is_unlocked
	
	if is_completed:
		text += " (✓)" # Simple text marker, replace with a green star icon later!

func _pressed():
	# When clicked, tell the menu which level was selected
	stage_selected.emit(level_data)
