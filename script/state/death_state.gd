class_name DeathState
extends State

@export var death_pop_velocity: float = -300.0
@export var delay_before_respawn: float = 1.0

func enter() -> void:
	sprite.play("hit")
	
	# 1. Turn off world collision so the player falls through floors out of the screen
	player.collision_layer = 0
	player.collision_mask = 0
	
	# 2. Give the player a classic arcade-style "pop" upward before falling
	velocity_comp.velocity.x = 0 # Stop horizontal movement
	velocity_comp.velocity.y = death_pop_velocity

func physics_update(delta: float) -> void:
	# 3. Apply gravity to make them drop off-screen
	velocity_comp.apply_gravity(delta)
	velocity_comp.move(player)
	
	# 4. Check if the player has completely fallen below the viewport
	var viewport_rect = player.get_viewport_rect()
	var player_screen_pos = player.get_global_transform_with_canvas().origin
	
	if player_screen_pos.y > viewport_rect.size.y + 64: # 64px padding safety margin
		# Stop physics updates for this state
		set_physics_process(false)
		
		# 5. Wait 1 second after falling out of bounds, then trigger respawn
		await player.get_tree().create_timer(delay_before_respawn).timeout
		
		# Notify the outside world via the player script
		player.player_respawn_ready.emit()
