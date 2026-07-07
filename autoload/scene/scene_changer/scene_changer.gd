extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

var level_container: Node = null
const FADE_TO_BLACK := "fade_to_black"
const FADE_FROM_BLACK := "fade_from_black"

# Simple cache to avoid reloading the same PackedScene repeatedly
var _scene_cache: Dictionary = {}

func _ready() -> void:
	# Ensure the screen is transparent when the game boots up
	color_rect.modulate.a = 0.0
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Call this from your Main script's _ready() function
func register_level_container(container: Node) -> void:
	level_container = container

func change_scene(target_scene_path: String) -> void:
	# 1. Block mouse inputs so the player can't click buttons mid-transition
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 2. Play the fade out animation
	animation_player.play(FADE_TO_BLACK)
	await animation_player.animation_finished
	
	# 3. Swap the scene behind the black screen
	get_tree().change_scene_to_file(target_scene_path)
	
	# 4. Wait a brief moment for the new scene to initialize
	await get_tree().process_frame
	
	# 5. Play the fade in animation
	animation_player.play(FADE_FROM_BLACK)
	await animation_player.animation_finished
	
	# 6. Allow mouse inputs again
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func switch_level(level_path: String) -> void:
	if not level_container:
		push_error("SceneManager: LevelContainer is not registered!")
		return
	# 1. Load the new level resource (use cache when possible)
	var new_level_scene = null
	if level_path in _scene_cache:
		new_level_scene = _scene_cache[level_path]
	else:
		new_level_scene = load(level_path)
		if new_level_scene:
			_scene_cache[level_path] = new_level_scene
	if not new_level_scene:
		push_error("Failed to load level path: " + level_path)
		return
	# 1. Block mouse inputs so the player can't click buttons mid-transition
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 2. Play the fade out animation
	animation_player.play(FADE_TO_BLACK)
	await animation_player.animation_finished
	
# 2. Safely free the current level
	for child in level_container.get_children():
		child.queue_free()

# 3. Instance the new level and add it to the scene tree
	var new_level = new_level_scene.instantiate()
	level_container.add_child(new_level)
	
	# 4. Wait a brief moment for the new scene to initialize
	await get_tree().process_frame
	
	# 5. Play the fade in animation
	animation_player.play(FADE_FROM_BLACK)
	await animation_player.animation_finished
	
	# 6. Allow mouse inputs again
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
