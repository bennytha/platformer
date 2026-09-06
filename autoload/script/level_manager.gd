# LevelManager.gd
extends Node

const SAVE_PATH = "user://save_data.cfg"

# Drop all your level .tres files here in the Inspector
@export var all_levels: Array[LevelModel] = [
	preload("uid://dnt4pljifhh65"),
	preload("uid://bhv37fjlm7qo"),
	preload("uid://cmvni7tplo3kr"),
	preload("uid://bdhr2m6okmk8g"),
	preload("uid://ymhbwppsj00o"),
	preload("uid://c1x2wi6y2ufuk"),
	preload("uid://bd82lhudtmy35"),
	preload("uid://3675oi8t8d1k"),
	preload("uid://bd2wc08rdkf5g"),
	preload("uid://ds2xa3fyryfdy"),
	preload("uid://cbqvu71t1yv8o"),
	preload("uid://dvhqod7fpjfp5"),
	preload("uid://domsl0qpclbip"),
	preload("uid://bekdpwomsqnic"),
	preload("uid://cn66w36y0syf2"),
	preload("uid://bjfmpt1b4r6ss"),
	preload("uid://dfycbtg3bqslo"),
	preload("uid://dyy13yhj4fy2b"),
	preload("uid://cibvd12gs71gx"),
	preload("uid://ca3l7hu62qbab"),
	preload("uid://bfpfwqvv7vg3a"),
	preload("uid://n4dba0ag3ebn"),
	preload("uid://b25tvo0p5c23o"),
	preload("uid://dyqac3pe8g2hk"),
	preload("uid://dy45pwxgr0ero"),
	preload("uid://2x74t1d33m8"),
	preload("uid://mk03p3uhctd2"),
	preload("uid://bmci0h6tcvfw8"),
	preload("uid://dpijbuoap1bi"),
	preload("uid://bxx72bpyyawye"),
	preload("uid://ex31h078d3js"),
	preload("uid://c7cyhssa353dg"),
	preload("uid://dykttyyelqhe"),
	preload("uid://i1ckxby2na56"),
	preload("uid://ug8xh40t5d0i"),
	preload("uid://bl0u3lmbisuwb"),
	preload("uid://dagv6t2h8cbiy"),
	preload("uid://c1l4lwy1oydyo"),
	preload("uid://c7agds1txly0j"),
	preload("uid://dsaflb55au6xq"),
	
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

func get_meta_data(level_id: String) -> Dictionary:
	if player_progress.has(level_id):
		return player_progress[level_id].duplicate(true)
	return {}

func complete_level(level_id: String, level_meta_data: Dictionary):
	if not player_progress.has(level_id):
		player_progress[level_id] = {}
	player_progress[level_id]["completed"] = true
	if level_meta_data and level_meta_data.has("total"):
		var previous_total: int = int(player_progress[level_id].get("total", 0))
		var new_total: int = int(level_meta_data.get("total", 0))
		if previous_total <= new_total:
			player_progress[level_id]["lives"] = int(level_meta_data.get("lives", 0))
			player_progress[level_id]["collectables"] = int(level_meta_data.get("collectables", 0))
			player_progress[level_id]["time_in_seconds"] = float(level_meta_data.get("time_in_seconds", 0))
			player_progress[level_id]["total"] = new_total
			
	# extra features
	#player_progress[level_id]["stars_earned"] = 3
	#player_progress[level_id]["best_time"] = 42.5
	save_game()
	
func get_next_level(current_level_id: String) -> LevelModel:
	var current_index := -1
	for i in range(all_levels.size()):
		if all_levels[i].level_id == current_level_id:
			current_index = i
			break

	if current_index == -1 or current_index + 1 >= all_levels.size():
		return null

	return all_levels[current_index + 1]

func is_new_game() -> bool:
	for level in all_levels:
		if is_level_completed(level.level_id):
			return false
	return true

func get_game_start_info() -> Dictionary:
	if all_levels.is_empty():
		return {"label": "New Game", "level": null}

	if is_new_game():
		return {"label": "New Game", "level": all_levels[0]}

	var last_unlocked_uncompleted: LevelModel = null
	var last_unlocked: LevelModel = all_levels[0]
	var previous_completed := true

	for i in range(all_levels.size()):
		var current_level := all_levels[i]
		var is_completed := is_level_completed(current_level.level_id)
		var is_unlocked := (i == 0) or previous_completed

		if is_unlocked:
			last_unlocked = current_level
			if not is_completed:
				last_unlocked_uncompleted = current_level

		previous_completed = is_completed

	var target_level = last_unlocked_uncompleted if last_unlocked_uncompleted != null else last_unlocked

	return {
		"label": "Continue",
		"level": target_level
	}

	
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

func reset_game():
	player_progress.clear()
	save_game()
