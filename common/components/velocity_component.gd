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

var environmental_force: Vector2 = Vector2.ZERO

# Track last 10 velocity values with direction
var velocity_history: Array[Vector2] = []

func accelerate(direction: float, delta: float) -> void:
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func apply_gravity(delta: float) -> void:
	velocity.y = move_toward(velocity.y, max_fall_speed, gravity * delta)

func move(body: CharacterBody2D) -> void:
	body.velocity = velocity + environmental_force
	body.move_and_slide()
	# Sync back velocity after physics collisions
	velocity = body.velocity - environmental_force
	_update_velocity_history()

func _update_velocity_history() -> void:
	velocity_history.append(velocity)
	
	# Keep only last 10 values
	if velocity_history.size() > 10:
		velocity_history.pop_front()
