extends EnemyBase

@onready var head_hurtbox: Area2D = $HurtBox
@onready var wall_checker: RayCast2D = $WallChecker
@onready var ledge_checker: RayCast2D = $LedgeChecker
@onready var player_checker_l: RayCast2D = $PlayerCheckerL
@onready var player_checker_r: RayCast2D = $PlayerCheckerR

func _ready() -> void:
	transition_to_state(EnemyState.IDLE)

# Patrol State
func enter_patrol_state() -> void:
	velocity.x = direction * speed
	sprite.play("run")

func update_patrol_state(delta: float) -> void:
	apply_gravity(delta)

	if wall_checker.is_colliding() or not ledge_checker.is_colliding():
		velocity.x = 0.0
		transition_to_state(EnemyState.IDLE)
		return

	var player_direction: int = get_detected_player_direction()
	if player_direction != 0 and player_direction != direction:
		flip_direction(player_direction)

	velocity.x = direction * speed
	sprite.play("run")
	move_and_slide()

# Idle State
func enter_idle_state() -> void:
	velocity.x = 0.0
	sprite.play("idle")

func update_idle_state(delta: float) -> void:
	var player_direction: int = get_detected_player_direction()
	var blocked: bool = wall_checker.is_colliding() or not ledge_checker.is_colliding()

	if player_direction != 0:
		if blocked:
			if player_direction != direction:
				flip_direction(player_direction)
				transition_to_state(EnemyState.PATROL)
				return
			# If blocked and player is on the same side, stay idle.
			return

		if player_direction != direction:
			flip_direction(player_direction)
		transition_to_state(EnemyState.PATROL)
		return

	apply_gravity(delta)
	velocity.x = 0.0
	move_and_slide()

# Dying State
func enter_dying_state() -> void:
	head_hurtbox.set_deferred("monitoring", false)
	super.enter_dying_state()
	if sprite.sprite_frames.has_animation("hit"):
		sprite.play("hit")

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

	var collider = ray.get_collider()
	return collider != null and collider.is_in_group("player")

func flip_direction(new_direction: int = 0) -> void:
	var old_direction: int = direction
	if new_direction == 0:
		direction *= -1
	else:
		direction = new_direction

	if direction == old_direction:
		return

	sprite.flip_h = (direction > 0)

	wall_checker.target_position.x *= -1
	ledge_checker.position.x *= -1

	wall_checker.force_raycast_update()
	ledge_checker.force_raycast_update()

func _on_hurt_box_body_entered(body: Node2D) -> void:
	handle_player_contact(body)
