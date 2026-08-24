extends EnemyBase

@onready var wall_checker: RayCast2D = $WallChecker
@onready var ledge_checker: RayCast2D = $LedgeChecker
@onready var head_hurtbox: Area2D = $HurtBox
@onready var hit_box: Area2D = $HitBox
@onready var player_detection: Area2D = $PlayerDetection

func _ready() -> void:
	transition_to_state(EnemyState.IDLE)

# Patrol State
func enter_patrol_state() -> void:
	player_detection.set_deferred("monitoring", false)
	velocity.x = direction * speed
	_play_animation("run")

	await get_tree().create_timer(.5).timeout
	if current_state != EnemyState.PATROL:
		return

	head_hurtbox.set_deferred("monitoring", true)
	hit_box.set_deferred("monitoring", true)
	hit_box.collision_layer = GameConstants.DAMAGE_PLAYER_LAYER

func update_patrol_state(delta: float) -> void:
	apply_gravity(delta)

	if wall_checker.is_colliding() or not ledge_checker.is_colliding():
		_play_animation("shell_wall_hit")
		flip_direction()
		return

	velocity.x = direction * speed
	_play_animation("run")
	move_and_slide()
	

# Idle State
func enter_idle_state() -> void:
	velocity.x = 0.0
	_play_animation("idle")

func update_idle_state(delta: float) -> void:
	apply_gravity(delta)

# Dying State
func enter_dying_state() -> void:
	head_hurtbox.set_deferred("monitoring", false)
	hit_box.collision_layer = GameConstants.NON_PLAYER_INTERACTION_LAYER
	super.enter_dying_state()
	_play_animation("shell_top_hit")

func flip_direction() -> void:
	direction *= -1
	sprite.flip_h = (direction > 0)

	wall_checker.target_position.x *= -1
	ledge_checker.position.x *= -1

	wall_checker.force_raycast_update()
	ledge_checker.force_raycast_update()
	

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	_play_animation("shell_top_hit")
	handle_player_contact(body)


func _on_player_detection_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	body.velocity_component.velocity.y = -200
	
	var patrol_direction: int = sign(global_position.x - body.global_position.x)
	if patrol_direction == 0:
		patrol_direction = -direction

	if patrol_direction != direction:
		flip_direction()

	transition_to_state(EnemyState.PATROL)

func _play_animation(animation_name: StringName) -> void:
	if sprite.animation != animation_name:
		sprite.play(animation_name)
