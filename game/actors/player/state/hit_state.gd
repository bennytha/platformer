class_name HitState
extends State

@export var stun_duration: float = 0.25
var timer: float = 0.0

func enter() -> void:
	timer = 0.0
	# Example knockback: push back slightly depending on look direction
	velocity_comp.velocity.y = -150
	sprite.play('hit')

func physics_update(delta: float) -> void:
	timer += delta
	velocity_comp.apply_gravity(delta)
	velocity_comp.move(player) # Player cannot input move during hit
	
	if timer >= stun_duration:
		if player.is_on_floor():
			transitioned.emit("idle")
		else:
			transitioned.emit("fall")
