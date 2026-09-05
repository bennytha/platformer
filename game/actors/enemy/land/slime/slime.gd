extends EnemyBase

@onready var wall_checker: RayCast2D = $WallChecker
@onready var ledge_checker: RayCast2D = $LedgeChecker
@onready var head_hurtbox: Area2D = $HurtBox
@onready var hit_box: Area2D = $HitBox
@onready var timer: Timer = $Timer
const SLIME_PARTICLE = preload("uid://dm7c1iv1sepbt")
@onready var spawn_point: Marker2D = $spawnPoint

func _ready() -> void:
	transition_to_state(EnemyState.PATROL)

# Patrol State
func enter_patrol_state() -> void:
	velocity.x = direction * speed
	sprite.play("run")

func update_patrol_state(delta: float) -> void:
	apply_gravity(delta)

	if wall_checker.is_colliding() or not ledge_checker.is_colliding():
		flip_direction()

	velocity.x = direction * speed
	sprite.play("run")
	move_and_slide()

# Dying State
func enter_dying_state() -> void:
	head_hurtbox.set_deferred("monitoring", false)
	hit_box.collision_layer = 1 << 5  # Layer 3
	super.enter_dying_state()
	if sprite.sprite_frames.has_animation("hit"):
		sprite.play("hit")

func flip_direction() -> void:
	direction *= -1
	sprite.flip_h = (direction > 0)

	wall_checker.target_position.x *= -1
	ledge_checker.position.x *= -1
	spawn_point.position.x *= -1
	wall_checker.force_raycast_update()
	ledge_checker.force_raycast_update()

func _on_hurt_box_body_entered(body: Node2D) -> void:
	timer.stop()
	handle_player_contact(body)

func _on_timer_timeout() -> void:
	spawn_particle()
	timer.wait_time = randf_range(0.1, 0.4)
	
func spawn_particle():
	var particle = SLIME_PARTICLE.instantiate()
	particle.global_position = spawn_point.global_position
	get_parent().add_child(particle)
