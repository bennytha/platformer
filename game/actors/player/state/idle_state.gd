class_name IdleState
extends State

func enter() -> void:
	sprite.play('idle')
	
func physics_update(delta: float) -> void:
	velocity_comp.apply_gravity(delta)
	velocity_comp.accelerate(0, delta) # Apply friction
	velocity_comp.move(player)
	
	if not player.is_on_floor():
		transitioned.emit("fall")
		return
	
	if input_comp.x_axis != 0:
		transitioned.emit("run")
	elif input_comp.is_jump_just_pressed():
		transitioned.emit("jump")
