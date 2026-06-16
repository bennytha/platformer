extends CharacterBody2D

@export var float_amplitude : float = 2.0  # How high it bobs up and down
@export var float_speed : float = 3.0      # How fast it bobs
@export var fall_speed : float = 400.0     # How fast it drops

enum FloatingState { FLOATING, SHAKING, FALLING }
var current_state : FloatingState = FloatingState.FLOATING

var start_y : float
var time_passed : float = 0.0
var shake_tween : Tween

@onready var collapse_timer : Timer = $CollapseTimer
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	start_y = global_position.y
	$DetectionArea.body_entered.connect(_on_player_entered)
	collapse_timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta: float) -> void:
	match current_state:
		FloatingState.FLOATING:
			_handle_floating(delta)
		FloatingState.SHAKING:
			# Shaking is handled entirely by a Tween for smoothness, 
			# so we don't need code running here.
			pass
		FloatingState.FALLING:
			_handle_falling(delta)

# --- State Behaviors ---

func _handle_floating(delta: float) -> void:
	time_passed += delta * float_speed
	# Use a math sine wave to calculate a smooth up/down motion
	global_position.y = start_y + (sin(time_passed) * float_amplitude)

func _handle_falling(delta: float) -> void:
	# Move the platform downwards
	velocity.y = fall_speed
	move_and_slide()

# --- Signal Callbacks ---

func _on_player_entered(body: Node2D) -> void:
	# Make sure it's the player and we aren't already collapsing
	if body.is_in_group("player") and current_state == FloatingState.FLOATING:
		current_state = FloatingState.SHAKING
		collapse_timer.start() # Default wait_time set in Inspector (e.g., 1.5 seconds)
		_player_weight_reaction()
		_start_shaking_effect()

func _on_timer_timeout() -> void:
	if shake_tween:
		shake_tween.kill() # Stop the shaking animation
	current_state = FloatingState.FALLING
	
	cpu_particles_2d.emitting = false
	animated_sprite_2d.play("off")

	# Optional: Turn off collisions so it falls *through* the world/player
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

func _player_weight_reaction() -> void:
	const  weight_offset = 10.0
	var down_tween = create_tween()
	down_tween.tween_property(self, "global_position:y", global_position.y + weight_offset, 0.20).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _start_shaking_effect() -> void:
	# Create a fast, looping shake using Godot 4 Tweens
	shake_tween = create_tween().set_loops()
	
	# Quickly offset the sprite or position left and right
	var shake_offset = 1.0
	shake_tween.tween_property(self, "global_position:x", global_position.x + shake_offset, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	shake_tween.tween_property(self, "global_position:x", global_position.x - shake_offset, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
