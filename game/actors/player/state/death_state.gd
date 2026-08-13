class_name DeathState
extends State

@export var death_pop_velocity: float = -300.0
@export var delay_before_respawn: float = 1.0
@export var death_rotation_amount: float = 180.0
@export var death_rotation_time: float = 0.8
@export var death_force: float = 180.0

func enter() -> void:
	sprite.play("hit")
	# 1. Turn off world collision so the player falls through floors out of the screen
	player.collision_layer = 0
	player.collision_mask = 0
	player.z_index = 2
	
	# 2. Give the player a classic arcade-style "pop" upward before falling
	velocity_comp.velocity.x = player.last_hit_direction * death_force
	velocity_comp.velocity.y = death_pop_velocity
	
	# 3. Apply rotation based on hit direction
	apply_death_rotation()
	
	play_death_sound()

func physics_update(delta: float) -> void:
	# 3. Apply gravity to make them drop off-screen
	velocity_comp.apply_gravity(delta)
	velocity_comp.move(player)
	
	# Stop physics updates for this state
	set_physics_process(false)
		
	# 5. Wait 1 second after falling out of bounds, then trigger respawn
	await player.get_tree().create_timer(delay_before_respawn).timeout
		
	# Notify the outside world via the player script
	EventBus.player_died.emit()
	player.queue_free()
	
func apply_death_rotation() -> void:
	var hit_direction: float = player.last_hit_direction
	if hit_direction == 0:
		hit_direction = 1.0
	
	var target_rotation: float = player.rotation + (deg_to_rad(death_rotation_amount) * hit_direction)
	var tween: Tween = create_tween()
	tween.tween_property(player, "rotation", target_rotation, death_rotation_time)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

func play_death_sound():
	await get_tree().create_timer(.5).timeout
	AudioManager.play_sfx(preload("uid://cpgyry20g6q2o"))
	
