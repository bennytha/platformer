class_name DoubleJumpState
extends State

@export var double_jump_velocity: float = -350.0

func enter() -> void:
	velocity_comp.velocity.y = double_jump_velocity

func physics_update(delta: float) -> void:
	velocity_comp.apply_gravity(delta)
	velocity_comp.accelerate(input_comp.x_axis, delta)
	velocity_comp.move(player)
	
	if velocity_comp.velocity.y >= 0:
		transitioned.emit("fall")
