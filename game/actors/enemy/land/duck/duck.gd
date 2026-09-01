extends EnemyBase


# --- Specific Duck Exports ---
@export_group("Duck Patrol")
@export var patrol_distance: float = 200.0
@export var jump_force: float = -300.0
@export var idle_duration: float = 0.5

# --- Specific Duck Animations ---
@export_group("Duck Animations")
@export var anim_idle: String = "idle"
@export var anim_anticipation: String = "jump_anticipation"
@export var anim_jump: String = "jump"
@export var anim_fall: String = "fall"

var start_x: float = 0.0
var idle_timer: float = 0.0

@onready var head_hurtbox: Area2D = $HurtBox
@onready var hit_box: Area2D = $HitBox

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	transition_to_state(EnemyState.IDLE)

# Idle State
func enter_idle_state() -> void:
	velocity.x = 0.0
	idle_timer = idle_duration
	sprite.play("idle")

func update_idle_state(delta: float) -> void:
	apply_gravity(delta)
	velocity.x = 0.0
	move_and_slide()
	
	idle_timer -= delta
	if idle_timer <= 0.0:
		start_anticipation_and_hop()

# jump State
func enter_jump_state() -> void:
	start_x = global_position.x
	velocity.y = jump_force
	velocity.x = direction * speed
	sprite.play("jump")

func update_jump_state(delta: float) -> void:
	apply_gravity(delta)
	velocity.x = direction * speed
	move_and_slide()
	
	if velocity.y > 0.0 and not is_on_floor():
		transition_to_state(EnemyState.FALL)
	check_ground_landing()

# fall State
func enter_fall_state() -> void:
	sprite.play("fall")

func update_fall_state(delta: float) -> void:
	apply_gravity(delta)
	move_and_slide()
	check_ground_landing()

# Dying State
func enter_dying_state() -> void:
	head_hurtbox.set_deferred("monitoring", false)
	hit_box.collision_layer = 1 << 5  # Layer 3
	super.enter_dying_state()
	if sprite.sprite_frames.has_animation("hit"):
		sprite.play("hit")

func _on_animation_finished() -> void:
	if current_state == EnemyState.IDLE and sprite.animation == "idle":
		flip_direction()
		transition_to_state(EnemyState.PATROL)

func flip_direction() -> void:
	direction *= -1
	sprite.flip_h = (direction > 0)

# --- Anticipation -> Jump ---
func start_anticipation_and_hop() -> void:
	sprite.play('jump_anticipation')
	await sprite.animation_finished
	
	if current_state == EnemyState.DYING:
		return

	transition_to_state(EnemyState.JUMP)
	
# --- Landing & Patrol Bounds Checking ---
func check_ground_landing() -> void:
	if is_on_floor():
		velocity.x = 0.0

		var distance_traveled: float = (global_position.x - start_x) * direction
		var x_moved: bool = abs(global_position.x - start_x) > 1.0

		if distance_traveled >= patrol_distance or not x_moved:
			flip_direction()
			start_x = global_position.x

		transition_to_state(EnemyState.IDLE)


func _on_hurt_box_body_entered(body: Node2D) -> void:
	handle_player_contact(body)
