extends EnemyBase

@onready var head_hurtbox: Area2D = $HurtBox
@onready var hit_box: Area2D = $HitBox
@onready var player_checker: Area2D = $PlayerChecker

@export var patrol_amplitude: float = 8.0
@export var patrol_frequency: float = 2.0

var initial_global_position: Vector2
var patrol_time: float = 0.0
var has_landed: bool = false

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	initial_global_position = global_position
	enter_patrol_state()

# Patrol State
func enter_patrol_state() -> void:
	has_landed = false
	sprite.play("idle")

func update_patrol_state(delta: float) -> void:
	patrol_time += delta
	var target_position := initial_global_position
	target_position.y += sin(patrol_time * patrol_frequency * TAU) * patrol_amplitude
	velocity = (target_position - global_position) / max(delta, 0.001)
	sprite.play("idle")
	move_and_slide()

# Patrol State
func enter_fall_state() -> void:
	has_landed = false
	sprite.play("fall")

func update_fall_state(delta: float) -> void:
	apply_gravity(delta)
	move_and_slide()
	if is_on_floor_only() and not has_landed:
		has_landed = true
		velocity = Vector2.ZERO
		sprite.play('ground')
	
# Idle State
func enter_idle_state() -> void:
	velocity.y = 0.0
	sprite.play("idle")

func update_idle_state(delta: float) -> void:
	apply_gravity(delta)
	velocity.y = 0.0
	move_and_slide()

# Air Patrol State
func enter_air_patrol_state() -> void:
	velocity = Vector2.ZERO
	sprite.play("idle")

func update_air_patrol_state(delta: float) -> void:
	var distance_to_start := global_position.distance_to(initial_global_position)
	if distance_to_start <= speed * delta:
		global_position = initial_global_position
		velocity = Vector2.ZERO
		transition_to_state(EnemyState.PATROL)
		return

	velocity = global_position.direction_to(initial_global_position) * speed
	sprite.play("idle")
	move_and_slide()

# Dying State
func enter_dying_state() -> void:
	head_hurtbox.set_deferred("monitoring", false)
	hit_box.collision_layer = 1 << 5  # Layer 3
	super.enter_dying_state()
	if sprite.sprite_frames.has_animation("hit"):
		sprite.play("hit")

func _on_animation_finished() -> void:
	if sprite.animation == "ground":
		transition_to_state(EnemyState.AIR_PATROL)

func _on_player_checker_body_entered(_body: Node2D) -> void:
	if current_state == EnemyState.PATROL or current_state == EnemyState.AIR_PATROL:
		transition_to_state(EnemyState.FALL)


func _on_hurt_box_body_entered(body: Node2D) -> void:
	handle_player_contact(body)
