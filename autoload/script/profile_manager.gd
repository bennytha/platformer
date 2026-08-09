# ProfileManager.gd
extends Node

# Signals to update your UI cleanly
signal xp_gained(amount, current_xp, xp_needed)
signal level_up(new_level)

const SAVE_PATH: String = "user://savegame.tres"

var current_level: int = 1
var current_xp: int = 0

func _ready() -> void:
	load_game()

func get_current_stats() -> Dictionary:
	var data = {
		level= current_level,
		xp= current_xp,
		xp_needed = get_required_xp(current_level)
	}
	return data
	
# Convert final gameplay score into XP (e.g., 1 Score = 1 XP)
func add_end_game_score(score: int) -> void:
	# You can add a multiplier here if needed
	var xp_gained_amount = int(score / 10.0)
	current_xp += xp_gained_amount
	
	# Handle multiple level-ups if the score is huge
	while current_xp >= get_required_xp(current_level):
		current_xp -= get_required_xp(current_level)
		current_level += 1
		
		level_up.emit(current_level)
	xp_gained.emit(xp_gained_amount, current_xp, get_required_xp(current_level))

func get_required_xp(level: int) -> int:
	return int(100.0 * pow(level, 1.1))

func save_game() -> void:
	var data := SaveData.new()
	data.current_level = current_level
	data.current_xp = current_xp
	
	var error := ResourceSaver.save(data, SAVE_PATH)
	if error != OK:
		print("Failed to save game! Error code: ", error)
	else:
		print("Game saved successfully.")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Starting fresh.")
		return
		
	var data := ResourceLoader.load(SAVE_PATH) as SaveData
	if data:
		current_level = data.current_level
		current_xp = data.current_xp
		print("Game loaded successfully.")
	else:
		print("Failed to load save file format.")

func reset_save() -> void:
	current_level = 1
	current_xp = 0
	
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save file deleted.")
	
	save_game()
