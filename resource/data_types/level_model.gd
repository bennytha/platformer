class_name LevelModel
extends Resource

@export var level_id: String       # Unique ID (e.g., "world_1_level_1")
@export var level_name: String     # Display name
@export var scene_path: String     # Path to the actual .tscn file
@export var order: int             # Order in the stage select screen
