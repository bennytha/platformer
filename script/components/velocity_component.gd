class_name VelocityComponent
extends Node

@export_group("Horizontal Movement")
@export var speed: float = 200.0
@export var acceleration: float = 1200.0
@export var friction: float = 1500.0

@export_group("Vertical Movement")
@export var gravity: float = 980.0
@export_group("Vertical Movement")
@export var max_fall_speed: float = 500.0

var velocity: Vector2 = Vector2.ZERO

func accelerate(direction: float, delta: float) -> void:
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func apply_gravity(delta: float) -> void:
	velocity.y = move_toward(velocity.y, max_fall_speed, gravity * delta)

func move(body: CharacterBody2D) -> void:
	body.velocity = velocity
	body.move_and_slide()
	# Sync back velocity after physics collisions
	velocity = body.velocity
