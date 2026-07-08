# LevelManager.gd
extends Node

const SAVE_PATH = "user://save_data.cfg"

# Drop all your level .tres files here in the Inspector
@export var all_levels: Array[LevelModel] = [
	preload("uid://dnt4pljifhh65"),
	preload("uid://bhv37fjlm7qo")
]

# This dictionary will store runtime player progress
# Example: {"world_1_level_1": {"completed": true, "high_score": 2500}}
var player_progress: Dictionary = {}

func _ready():
	# Sort levels by their 'order' property automatically
	all_levels.sort_custom(func(a, b): return a.order < b.order)
	load_game()

func is_level_completed(level_id: String) -> bool:
	if player_progress.has(level_id):
		return player_progress[level_id].get("completed", false)
	return false

func complete_level(level_id: String):
	if not player_progress.has(level_id):
		player_progress[level_id] = {}
	player_progress[level_id]["completed"] = true
	# extra features
	#player_progress[level_id]["stars_earned"] = 3
	#player_progress[level_id]["best_time"] = 42.5
	save_game()
	
func save_game():
	var config = ConfigFile.new()
	
	# Store the progress dictionary under a "Progress" section
	config.set_value("Progress", "player_levels", player_progress)
	
	# Save to the user's persistent device storage
	var error = config.save(SAVE_PATH)
	if error != OK:
		print("Failed to save game data!")

func load_game():
	var config = ConfigFile.new()
	var error = config.load(SAVE_PATH)
	
	# If the file doesn't exist yet (first time playing), initialize empty data
	if error != OK:
		player_progress = {}
		return
		
	# Retrieve the data, defaulting to an empty dictionary if it's missing
	player_progress = config.get_value("Progress", "player_levels", {})
