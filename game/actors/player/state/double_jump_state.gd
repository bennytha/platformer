class_name DoubleJumpState
extends State

@export var double_jump_velocity: float = -350.0

func enter() -> void:
	velocity_comp.velocity.y = double_jump_velocity
	sprite.play('double_jump')
	
	FallState.has_double_jumped = true

func physics_update(delta: float) -> void:
	velocity_comp.apply_gravity(delta)
	velocity_comp.accelerate_air(input_comp.x_axis, delta)
	velocity_comp.move(player)
	
	if velocity_comp.velocity.y >= 0:
		transitioned.emit("fall")
