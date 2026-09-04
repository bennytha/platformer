extends EnemyBase

@export var attack_interval: float = 1.5
@export var attack_shoot_frame: int = 8

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hit_box: Area2D = $HitBox
@onready var hit_box_2: Area2D = $HitBox2
@onready var hurt_box: Area2D = $HurtBox
@onready var wall_checker: RayCast2D = $WallChecker
@onready var ledge_checker: RayCast2D = $LedgeChecker
@onready var shoot_timer: Timer = $ShootTimer
@onready var player_checker_l: RayCast2D = $PlayerCheckerL
@onready var player_near_checker_l: RayCast2D = $PlayerNearCheckerL
@onready var player_checker_r: RayCast2D = $PlayerCheckerR
@onready var player_near_checker_r: RayCast2D = $PlayerNearCheckerR

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_sprite_frame_changed)
	transition_to_state(EnemyState.IDLE)

# Idle State
func enter_idle_state() -> void:
	velocity.x = 0.0
	sprite.play("idle")

func update_idle_state(delta: float) -> void:
	var player_near: bool = is_player_near()
	var detected_direction: int = get_player_direction()
	if detected_direction != 0:
		set_direction(detected_direction)

	if player_near and shoot_timer.is_stopped():
		transition_to_state(EnemyState.ATTACKING)
		return

	wall_checker.force_raycast_update()
	ledge_checker.force_raycast_update()
	if wall_checker.is_colliding() or not ledge_checker.is_colliding():
		velocity.x = 0.0
		apply_gravity(delta)
		move_and_slide()
		return

	if detected_direction != 0:
		if not player_near:
			transition_to_state(EnemyState.FOLLOW)
		return

	apply_gravity(delta)
	velocity.x = 0.0
	move_and_slide()

# Follow State
func enter_follow_state() -> void:
	velocity.x = direction * speed
	sprite.play("run")

func update_follow_state(delta: float) -> void:
	apply_gravity(delta)

	var detected_direction: int = get_player_direction()
	if detected_direction == 0:
		transition_to_state(EnemyState.IDLE)
		return

	set_direction(detected_direction)
	if is_player_near():
		if shoot_timer.is_stopped():
			transition_to_state(EnemyState.ATTACKING)
		else:
			transition_to_state(EnemyState.IDLE)
		return

	wall_checker.force_raycast_update()
	ledge_checker.force_raycast_update()
	if wall_checker.is_colliding() or not ledge_checker.is_colliding():
		transition_to_state(EnemyState.IDLE)
		return

	velocity.x = direction * speed
	sprite.play("run")
	move_and_slide()

# Attacking State
func enter_attacking_state() -> void:
	velocity.x = 0.0
	sprite.play("attack")
	shoot_timer.start(attack_interval)

func update_attacking_state(delta: float) -> void:
	apply_gravity(delta)
	velocity.x = 0.0
	move_and_slide()

# -------------------------------------
func is_player_near() -> bool:
	return is_player_detected(player_near_checker_l) or is_player_detected(player_near_checker_r)

func is_player_in_front() -> bool:
	return is_player_detected(get_active_player_checker())

func get_player_direction() -> int:
	if is_player_detected(player_checker_l) or is_player_detected(player_near_checker_l):
		return -1
	if is_player_detected(player_checker_r) or is_player_detected(player_near_checker_r):
		return 1
	return 0

func get_active_player_checker() -> RayCast2D:
	return player_checker_l if direction == -1 else player_checker_r

func is_player_detected(ray: RayCast2D) -> bool:
	ray.force_raycast_update()
	if not ray.is_colliding():
		return false

	var collider = ray.get_collider()
	return collider != null and collider.is_in_group("player")

func set_direction(new_direction: int) -> void:
	if new_direction == 0 or new_direction == direction:
		return

	direction = new_direction
	sprite.flip_h = direction > 0
	sprite.position.x = 38.0 if direction > 0 else 0.0
	wall_checker.target_position.x = abs(wall_checker.target_position.x) * direction
	ledge_checker.position.x = abs(ledge_checker.position.x) * direction
	wall_checker.force_raycast_update()
	ledge_checker.force_raycast_update()

func _on_animation_finished() -> void:
	if current_state == EnemyState.ATTACKING and sprite.animation == "attack":
		transition_to_state(EnemyState.IDLE)

func _on_sprite_frame_changed() -> void:
	if sprite.animation == "attack" and sprite.frame >= 6 and sprite.frame <= 9:
		hit_box_2.collision_layer = GameConstants.DAMAGE_PLAYER_LAYER
	else:
		hit_box_2.collision_layer = GameConstants.NON_PLAYER_INTERACTION_LAYER

func flip_direction() -> void:
	set_direction(-direction)
	
func _on_hurt_box_body_entered(body: Node2D) -> void:
	handle_player_contact(body)
