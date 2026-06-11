class_name WallSlideState
extends State

@export var wall_slide_speed: float = 100.0

func physics_update(delta: float) -> void:
	# Clamp descending speed for the slide effect
	velocity_comp.apply_gravity(delta)
	velocity_comp.velocity.y = min(velocity_comp.velocity.y, wall_slide_speed)
	
	velocity_comp.accelerate(input_comp.x_axis, delta)
	velocity_comp.move(player)
	
	if player.is_on_floor():
		transitioned.emit("idle")
		return
		
	if not player.is_on_wall():
		transitioned.emit("fall")
		return
		
	if input_comp.is_jump_just_pressed():
		# Simple wall jump away from wall
		velocity_comp.velocity.x = -input_comp.x_axis * velocity_comp.speed
		transitioned.emit("jump")
