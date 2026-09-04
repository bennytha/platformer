class_name EnemyBase
extends CharacterBody2D

enum EnemyState { PATROL, AIR_PATROL, JUMP, FALL, IDLE, FOLLOW, DYING, ATTACKING }

@export var speed: float = 60.0
@export var gravity: float = 980.0
@export var death_force: float = 80.0
@export var death_rotation_amount: float = 180.0
@export var death_rotation_time: float = 0.8
@export var death_timer_length: float = 1.0
@export var death_animation_name: String = "hit"

var current_state: EnemyState = EnemyState.PATROL
var direction: int = -1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _physics_process(delta: float) -> void:
	match current_state:
		EnemyState.PATROL:
			update_patrol_state(delta)
		EnemyState.AIR_PATROL:
			update_air_patrol_state(delta)
		EnemyState.IDLE:
			update_idle_state(delta)
		EnemyState.FOLLOW:
			update_follow_state(delta)
		EnemyState.JUMP:
			update_jump_state(delta)
		EnemyState.FALL:
			update_fall_state(delta)
		EnemyState.ATTACKING:
			update_attacking_state(delta)
		EnemyState.DYING:
			update_dying_state(delta)

func transition_to_state(new_state: EnemyState) -> void:
	if current_state == new_state:
		return
		
	current_state = new_state
	
	match current_state:
		EnemyState.PATROL:
			enter_patrol_state()
		EnemyState.IDLE:
			enter_idle_state()
		EnemyState.FOLLOW:
			enter_follow_state()
		EnemyState.JUMP:
			enter_jump_state()
		EnemyState.FALL:
			enter_fall_state()
		EnemyState.ATTACKING:
			enter_attacking_state()
		EnemyState.DYING:
			enter_dying_state()

# States---------------------------------
# Patrol State
func enter_patrol_state() -> void:
	pass

func update_patrol_state(delta: float) -> void:
	apply_gravity(delta)
	move_and_slide()

# Air Patrol State
func enter_air_patrol_state() -> void:
	pass

func update_air_patrol_state(delta: float) -> void:
	apply_gravity(delta)
	move_and_slide()

# Idle State
func enter_idle_state() -> void:
	pass

func update_idle_state(delta: float) -> void:
	apply_gravity(delta)
	move_and_slide()
	
# Follow State
func enter_follow_state() -> void:
	pass

func update_follow_state(delta: float) -> void:
	apply_gravity(delta)
	move_and_slide()

# Jump State
func enter_jump_state() -> void:
	pass

func update_jump_state(delta: float) -> void:
	apply_gravity(delta)
	move_and_slide()

# Fall State
func enter_fall_state() -> void:
	pass

func update_fall_state(delta: float) -> void:
	apply_gravity(delta)
	move_and_slide()

# Attacking State
func enter_attacking_state() -> void:
	pass

func update_attacking_state(delta: float) -> void:
	apply_gravity(delta)
	move_and_slide()

# Dying State
func enter_dying_state() -> void:
	velocity.x = 0.0

	if audio_stream_player_2d != null:
		audio_stream_player_2d.play()

	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)

	if sprite != null and sprite.sprite_frames != null:
		var animation_name: String = death_animation_name
		if animation_name.is_empty():
			animation_name = "hit"

		if sprite.sprite_frames.has_animation(animation_name):
			sprite.play(animation_name)

func update_dying_state(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta

# --------------------------------------------

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

# Shared Death logic handled --------------
func handle_player_contact(body: Node2D) -> void:
	if current_state == EnemyState.DYING or not body.is_in_group("player"):
		return

	var bounce_force: float = -500.0

	if body.has_method("bounce"):
		body.bounce()
		if "JUMP_VELOCITY" in body:
			bounce_force = body.JUMP_VELOCITY
	elif "velocity" in body:
		body.velocity.y = bounce_force
		if "JUMP_VELOCITY" in body:
			bounce_force = body.JUMP_VELOCITY

	die_from_hit(body.global_position, bounce_force)

func die_from_hit(player_position: Vector2, player_jump_force: float) -> void:
	if current_state == EnemyState.DYING:
		return

	transition_to_state(EnemyState.DYING)

	var hit_direction: float = sign(global_position.x - player_position.x)
	if hit_direction == 0:
		hit_direction = 1.0

	var upward_pop: float = -abs(player_jump_force) * 0.5
	if upward_pop == 0:
		upward_pop = -200.0

	velocity.y = upward_pop
	velocity.x = hit_direction * death_force

	var target_rotation: float = rotation + (deg_to_rad(death_rotation_amount) * hit_direction)
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation", target_rotation, death_rotation_time)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

	get_tree().create_timer(death_timer_length).timeout.connect(queue_free)
# --------------------------------------------
