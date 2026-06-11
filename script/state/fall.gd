class_name FallState
extends State

@export var coyote_time: float = 0.1
var time_falling: float = 0.0
var can_coyote_jump: bool = false

func enter() -> void:
	time_falling = 0.0
	# Only allow coyote jump if we just came from idle or run
	can_coyote_jump = true 

func physics_update(delta: float) -> void:
	time_falling += delta
	velocity_comp.apply_gravity(delta)
	velocity_comp.accelerate(input_comp.x_axis, delta)
	velocity_comp.move(player)
	
	if player.is_on_floor():
		if velocity_comp.velocity.x == 0:
			transitioned.emit("idle")
		else:
			transitioned.emit("run")
		return

	# Coyote Time & Double Jump handling
	if input_comp.is_jump_just_pressed():
		if can_coyote_jump and time_falling <= coyote_time:
			transitioned.emit("jump")
		else:
			transitioned.emit("double_jump")
			
	# Wall Slide check
	if player.is_on_wall_only() and input_comp.x_axis != 0:
		transitioned.emit("wall_slide")
