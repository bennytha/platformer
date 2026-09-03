extends EnemyBase

@onready var wall_checker: RayCast2D = $WallChecker
@onready var ledge_checker: RayCast2D = $LedgeChecker
@onready var head_hurtbox: Area2D = $HurtBox
@onready var hit_box: Area2D = $HitBox

@export var child: PackedScene = null
@export var should_flip: bool = false

var dying:bool = false

func _ready() -> void:
	if should_flip:
		flip_direction()
	sprite.animation_finished.connect(_on_animation_finished)
	transition_to_state(EnemyState.PATROL)

# Patrol State
func enter_patrol_state() -> void:
	velocity.x = direction * speed
	sprite.play("run")

func update_patrol_state(delta: float) -> void:
	apply_gravity(delta)

	if wall_checker.is_colliding() or not ledge_checker.is_colliding():
		transition_to_state(EnemyState.IDLE)
		return

	velocity.x = direction * speed
	#sprite.play("run")
	move_and_slide()

# Idle State
func enter_idle_state() -> void:
	velocity.x = 0.0
	if dying:
		sprite.play('hit')
	else:
		sprite.play("idle")

func update_idle_state(delta: float) -> void:
	apply_gravity(delta)
	velocity.x = 0.0
	move_and_slide()

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

	wall_checker.target_position.x *= -1
	ledge_checker.position.x *= -1

	wall_checker.force_raycast_update()
	ledge_checker.force_raycast_update()

func spawn_children() -> void:
	for patrol_direction in [-1, 1]:
		var spawned_child: EnemyBase = child.instantiate()
		#spawned_child.direction = patrol_direction
		spawned_child.global_position = global_position + Vector2(patrol_direction * 8, -1)
		if patrol_direction == -1:
			spawned_child.should_flip = true
		#spawned_child.velocity = Vector2(patrol_direction * spawned_child.speed, -300)
		get_parent().call_deferred("add_child", spawned_child)

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if not body.is_in_group('player'):
		return
	dying = true
	transition_to_state(EnemyState.IDLE)
	if child != null:
		spawn_children()
		sprite.play('hit')
		if body.has_method("bounce"):
			body.bounce()
		velocity.y = -500
		get_tree().create_timer(.2).timeout.connect(queue_free)
	else:
		handle_player_contact(body)
