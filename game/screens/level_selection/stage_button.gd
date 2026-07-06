extends Button

var level_data: LevelModel

signal stage_selected(level_data: LevelModel)

func setup(data: LevelModel, is_unlocked: bool, is_completed: bool):
	level_data = data
	text = data.level_name
	
	# Visual feedback based on save state
	disabled = not is_unlocked
	
	if is_completed:
		text += " (✓)" # Simple text marker, replace with a green star icon later!

func _pressed():
	# When clicked, tell the menu which level was selected
	stage_selected.emit(level_data)
