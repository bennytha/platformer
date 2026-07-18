class_name ForceJumpState
extends State

var custom_bounce_force: float = -600.0

func enter() -> void:
	# 1. Apply the heavy upward force
	velocity_comp.velocity.y = custom_bounce_force
	
	# 2. Play a cool jump/stretch animation if you have one
	sprite.play("jump") 
	
	# 3. Refresh the player's double jump because they hit a trampoline!
	FallState.has_double_jumped = false

func physics_update(delta: float) -> void:
	velocity_comp.apply_gravity(delta)
	
	# Allow the player to steer left/right slightly while rising
	velocity_comp.accelerate_air(input_comp.x_axis, delta)
	velocity_comp.move(player)
	
	# Transition back to fall state once the upward momentum stops
	if velocity_comp.velocity.y >= 0:
		transitioned.emit("fall")
		return
		
	# Allow them to cancel into a double jump mid-flight if they want
	if input_comp.is_jump_just_pressed():
		transitioned.emit("double_jump")
