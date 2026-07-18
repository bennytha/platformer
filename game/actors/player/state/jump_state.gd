class_name JumpState
extends State

@export var jump_velocity: float = -400.0

func enter() -> void:
	velocity_comp.velocity.y = jump_velocity
	sprite.play('jump')

func physics_update(delta: float) -> void:
	velocity_comp.apply_gravity(delta)
	velocity_comp.accelerate_air(input_comp.x_axis, delta)
	velocity_comp.move(player)
	
	# Variable jump height (cut jump short if button released)
	if input_comp.is_jump_released() and velocity_comp.velocity.y < 0:
		velocity_comp.velocity.y *= 0.5
		
	if velocity_comp.velocity.y >= 0:
		transitioned.emit("fall")
		return
		
	if input_comp.is_jump_just_pressed():
		transitioned.emit("double_jump")
