extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	# Ensure the screen is transparent when the game boots up
	color_rect.modulate.a = 0.0
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func change_scene(target_scene_path: String) -> void:
	# 1. Block mouse inputs so the player can't click buttons mid-transition
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 2. Play the fade out animation
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	
	# 3. Swap the scene behind the black screen
	get_tree().change_scene_to_file(target_scene_path)
	
	# 4. Wait a brief moment for the new scene to initialize
	await get_tree().process_frame
	
	# 5. Play the fade in animation
	animation_player.play("fade_from_black")
	await animation_player.animation_finished
	
	# 6. Allow mouse inputs again
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
