extends EnemyBase

@onready var wall_checker: RayCast2D = $WallChecker
@onready var head_hurtbox: Area2D = $HurtBox
@onready var hit_box: Area2D = $HitBox
@onready var player_checker_l: RayCast2D = $PlayerCheckerL
@onready var player_checker_r: RayCast2D = $PlayerCheckerR

const CHARGE_DELAY: float = 0.6
const INITIAL_CHARGE_SPEED: float = 100.0
const MAX_CHARGE_SPEED: float = 600.0
const CHARGE_ACCELERATION: float = 300.0
const WALL_BOUNCE_SPEED: float = 200.0

var charge_delay_remaining: float = 0.0
var charge_speed: float = INITIAL_CHARGE_SPEED
var charge_direction: int = 0
var wall_hit_active: bool = false

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	transition_to_state(EnemyState.IDLE)

# Idle State
func enter_idle_state() -> void:
	velocity.x = 0.0
	sprite.play("idle")

func update_idle_state(delta: float) -> void:
	apply_gravity(delta)

	if charge_delay_remaining > 0.0:
		charge_delay_remaining -= delta
		if charge_delay_remaining <= 0.0:
			var detected_direction: int = get_detected_player_direction()
			if detected_direction != 0:
				charge_direction = detected_direction
			flip_direction(charge_direction)
			transition_to_state(EnemyState.ATTACKING)
			return

	var detected_direction: int = get_detected_player_direction()
	if detected_direction != 0 and charge_delay_remaining <= 0.0:
		charge_direction = detected_direction
		charge_delay_remaining = CHARGE_DELAY
		return

	velocity.x = 0.0
	move_and_slide()


# Charge State
func enter_attacking_state() -> void:
	charge_speed = INITIAL_CHARGE_SPEED
	wall_hit_active = false
	velocity.x = direction * charge_speed
	sprite.play("run")

func update_attacking_state(delta: float) -> void:
	apply_gravity(delta)

	if wall_hit_active:
		velocity.x = move_toward(velocity.x, 0.0, CHARGE_ACCELERATION * delta)
		move_and_slide()
		return

	charge_speed = move_toward(charge_speed, MAX_CHARGE_SPEED, CHARGE_ACCELERATION * delta)
	velocity.x = direction * charge_speed
	move_and_slide()

	if wall_checker.is_colliding() or is_on_wall():
		wall_hit_active = true
		velocity.x = -direction * WALL_BOUNCE_SPEED
		sprite.play("wall_hit")

# Dying State
func enter_dying_state() -> void:
	head_hurtbox.set_deferred("monitoring", false)
	hit_box.collision_layer = 1 << 5  # Layer 3
	super.enter_dying_state()
	if sprite.sprite_frames.has_animation("hit"):
		sprite.play("hit")

func _on_animation_finished() -> void:
	if current_state == EnemyState.ATTACKING and wall_hit_active and sprite.animation == "wall_hit":
		wall_hit_active = false
		charge_delay_remaining = 0.0
		transition_to_state(EnemyState.IDLE)
		return

	if current_state == EnemyState.IDLE and sprite.animation == "idle":
		return

func get_detected_player_direction() -> int:
	if is_player_detected(player_checker_l):
		return -1
	if is_player_detected(player_checker_r):
		return 1
	return 0

func is_player_detected(ray: RayCast2D) -> bool:
	ray.force_raycast_update()
	if not ray.is_colliding():
		return false

	var collider: Node = ray.get_collider()
	return collider != null and collider.is_in_group("player")

func flip_direction(new_direction: int = 0) -> void:
	if new_direction == 0:
		direction *= -1
	else:
		direction = new_direction

	sprite.flip_h = (direction > 0)

	wall_checker.target_position.x *= -1

	wall_checker.force_raycast_update()

func _on_hurt_box_body_entered(body: Node2D) -> void:
	handle_player_contact(body)
