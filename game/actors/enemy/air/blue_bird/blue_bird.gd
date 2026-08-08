extends EnemyBase

@onready var wall_checker: RayCast2D = $WallChecker
@onready var ledge_checker: RayCast2D = $LedgeChecker
@onready var head_hurtbox: Area2D = $HeadHurtbox

func _ready() -> void:
	transition_to_state(EnemyState.PATROL)

# Patrol State
func enter_patrol_state() -> void:
	velocity.x = direction * speed
	sprite.play("flying")

func update_patrol_state(delta: float) -> void:
	if wall_checker.is_colliding():
		transition_to_state(EnemyState.IDLE)
		return

	velocity.x = direction * speed
	#sprite.play("flying")
	move_and_slide()

# Idle State
func enter_idle_state() -> void:
	velocity.x = 0.0
	flip_direction()
	transition_to_state(EnemyState.PATROL)
	#sprite.play("idle")

#func update_idle_state(delta: float) -> void:
	##apply_gravity(delta)
	#velocity.x = 0.0
	#move_and_slide()

# Dying State
func enter_dying_state() -> void:
	head_hurtbox.set_deferred("monitoring", false)
	super.enter_dying_state()
	if sprite.sprite_frames.has_animation("hit"):
		sprite.play("hit")

func flip_direction() -> void:
	direction *= -1
	sprite.flip_h = (direction > 0)

	wall_checker.target_position.x *= -1

	wall_checker.force_raycast_update()

func _on_head_hurtbox_body_entered(body: Node2D) -> void:
	handle_player_contact(body)
