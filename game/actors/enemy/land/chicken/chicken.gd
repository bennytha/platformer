extends EnemyBase

@onready var head_hurtbox: Area2D = $HurtBox
@onready var wall_checker: RayCast2D = $WallChecker
@onready var ledge_checker: RayCast2D = $LedgeChecker
@onready var player_checker_l: RayCast2D = $PlayerCheckerL
@onready var player_checker_r: RayCast2D = $PlayerCheckerR

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	transition_to_state(EnemyState.IDLE)

# Patrol State
func enter_patrol_state() -> void:
	velocity.x = direction * speed
	sprite.play("run")

func update_patrol_state(delta: float) -> void:
	apply_gravity(delta)

	if wall_checker.is_colliding() or not ledge_checker.is_colliding():
		transition_to_state(EnemyState.IDLE)
		return

	if player_checker_l.is_colliding() or player_checker_r.is_colliding():
		if player_checker_l.is_colliding():
			flip_direction(-1)
		else:
			flip_direction(1)
		return
	velocity.x = direction * speed
	#sprite.play("run")
	move_and_slide()

# Idle State
func enter_idle_state() -> void:
	velocity.x = 0.0
	sprite.play("idle")

func update_idle_state(delta: float) -> void:
	if player_checker_l.is_colliding() or player_checker_r.is_colliding():
		if player_checker_l.is_colliding():
			flip_direction(-1)
		else:
			flip_direction(1)
		
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

func _on_animation_finished() -> void:
	if current_state == EnemyState.IDLE and sprite.animation == "idle":
		flip_direction()
		transition_to_state(EnemyState.PATROL)

func flip_direction(new_direction = null) -> void:
	if new_direction == null:
		direction *= -1
	else:
		direction = new_direction
	
	sprite.flip_h = (direction > 0)

	wall_checker.target_position.x *= -1
	ledge_checker.position.x *= -1

	wall_checker.force_raycast_update()
	ledge_checker.force_raycast_update()

func _on_head_hurtbox_body_entered(body: Node2D) -> void:
	handle_player_contact(body)
