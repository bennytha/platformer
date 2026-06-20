class_name VelocityComponent
extends Node

@export_group("Horizontal Movement")
@export var base_speed: float = 200.0
@export var base_acceleration: float = 1200.0
@export var base_friction: float = 1500.0

@export_group("Vertical Movement")
@export var gravity: float = 980.0
@export var max_fall_speed: float = 500.0

# Active physics variables (modified on the fly by surfaces like Ice/Sand)
@onready var speed: float = base_speed
@onready var acceleration: float = base_acceleration
@onready var friction: float = base_friction

var velocity: Vector2 = Vector2.ZERO
var environmental_force: Vector2 = Vector2.ZERO

# State flags
var is_gravity_disabled: bool = false
var can_move: bool = true

# Track last 10 velocity values with direction
var velocity_history: Array[Vector2] = []

func accelerate(direction: float, delta: float) -> void:
	# If stuck in mud or stunned, naturally decelerate to a horizontal halt
	if not can_move:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		return
		
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func apply_gravity(delta: float) -> void:
	# Bypass gravity entirely if floating, hovering, or in a vertical wind tunnel
	if is_gravity_disabled:
		return
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

func reset_to_normal() -> void:
# Safely resets surface physics modifiers back to defaults
	speed = base_speed
	acceleration = base_acceleration
	friction = base_friction
	can_move = true
