class_name FallState
extends State

@export var coyote_time: float = 0.1
var time_falling: float = 0.0
var can_coyote_jump: bool = false

# This flag persists while the player is mid-air
static var has_double_jumped: bool = false

func enter() -> void:
	time_falling = 0.0
	sprite.play("fall")
	
	# If we just walked off a ledge, we can coyote jump
	if player.is_on_floor():
		can_coyote_jump = true

func physics_update(delta: float) -> void:
	time_falling += delta
	velocity_comp.apply_gravity(delta)
	velocity_comp.accelerate(input_comp.x_axis, delta)
	velocity_comp.move(player)
	
	if input_comp.x_axis > 0:
		sprite.flip_h = false
	elif input_comp.x_axis < 0:
		sprite.flip_h = true
	
	if player.is_on_floor():
		# LANDING: Reset the double jump tracking flag here!
		has_double_jumped = false
		
		if velocity_comp.velocity.x == 0:
			transitioned.emit("idle")
		else:
			transitioned.emit("run")
		return

	if input_comp.is_jump_just_pressed():
		# 1. Check for Coyote Time
		if can_coyote_jump and time_falling <= coyote_time:
			can_coyote_jump = false # Used it up
			transitioned.emit("jump")
		# 2. Check if we are allowed to Double Jump
		elif not has_double_jumped:
			transitioned.emit("double_jump")
			
	if player.is_on_wall_only() and input_comp.x_axis != 0:
		transitioned.emit("wall_slide")
