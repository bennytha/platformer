class_name RunState
extends State

func enter() -> void:
	sprite.play('run')

func physics_update(delta: float) -> void:
	velocity_comp.apply_gravity(delta)
	velocity_comp.accelerate(input_comp.x_axis, delta)
	velocity_comp.move(player)
	
	if input_comp.x_axis > 0:
		sprite.flip_h = false
	elif input_comp.x_axis < 0:
		sprite.flip_h = true
	
	if not player.is_on_floor():
		transitioned.emit("fall")
		return
		
	if input_comp.is_jump_just_pressed():
		transitioned.emit("jump")
	elif input_comp.x_axis == 0 and is_equal_approx(velocity_comp.velocity.x, 0.0):
		transitioned.emit("idle")
