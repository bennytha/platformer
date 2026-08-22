extends EnemyBase

@export var shell_speed: float = 240.0
@export var naked_body_texture: Texture2D

@onready var wall_checker: RayCast2D = $WallChecker
@onready var ledge_checker: RayCast2D = $LedgeChecker
@onready var head_hurtbox: Area2D = $HurtBox
@onready var hit_box: Area2D = $HitBox

func _ready() -> void:
	speed = 35.0
	death_animation_name = "shell_top_hit"
	sprite.animation_finished.connect(_on_animation_finished)
	
	head_hurtbox.body_entered.connect(_on_head_hurtbox_body_entered)
	hit_box.body_entered.connect(_on_hit_box_body_entered)
	
	transition_to_state(EnemyState.PATROL)

# =========================================================
# STATE IMPLEMENTATIONS
# =========================================================

# --- 1. PATROL (Walking with Body) ---
func enter_patrol_state() -> void:
	velocity.x = direction * speed
	sprite.play("walk")

func update_patrol_state(delta: float) -> void:
	apply_gravity(delta)
	
	if wall_checker.is_colliding() or not ledge_checker.is_colliding():
		flip_direction()

	velocity.x = direction * speed
	move_and_slide()

# --- 2. IDLE (Stationary Shell) ---
func enter_idle_state() -> void:
	velocity.x = 0.0
	sprite.play("shell_idle")

func update_idle_state(delta: float) -> void:
	apply_gravity(delta)
	velocity.x = 0.0
	move_and_slide()

# --- 3. ATTACKING (Fast Moving Shell) ---
func enter_attacking_state() -> void:
	velocity.x = direction * shell_speed
	sprite.play("shell_idle")

func update_attacking_state(delta: float) -> void:
	apply_gravity(delta)

	# Shell bounces off walls (ignore ledges so it slides over gaps/down stairs)
	if wall_checker.is_colliding() or is_on_wall():
		flip_direction()

	velocity.x = direction * shell_speed
	move_and_slide()

# --- 4. DYING (Shell Smashed) ---
func enter_dying_state() -> void:
	velocity = Vector2.ZERO
	head_hurtbox.set_deferred("monitoring", false)
	hit_box.set_deferred("monitoring", false)
	
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)
	if audio_stream_player_2d != null:
		audio_stream_player_2d.play()

	if sprite.sprite_frames.has_animation("shell_top_hit"):
		sprite.play("shell_top_hit")
	else:
		queue_free()

func update_dying_state(_delta: float) -> void:
	# Don't apply gravity/fly away like standard enemies; let the crush anim finish
	pass

# =========================================================
# HITBOX / COLLISION HANDLING
# =========================================================

# Player stomps the top
func _on_head_hurtbox_body_entered(body: Node2D) -> void:
	if current_state == EnemyState.DYING or not body.is_in_group("player"):
		return

	# Bounce player up
	if body.has_method("bounce"):
		body.bounce()
	elif "velocity" in body:
		body.velocity.y = -350.0

	match current_state:
		EnemyState.PATROL:
			_spawn_flying_body()
			transition_to_state(EnemyState.IDLE)

		EnemyState.IDLE, EnemyState.ATTACKING:
			transition_to_state(EnemyState.DYING)

# Player walks into side or kicks the shell
func _on_hit_box_body_entered(body: Node2D) -> void:
	if current_state == EnemyState.DYING or not body.is_in_group("player"):
		return

	match current_state:
		EnemyState.PATROL, EnemyState.ATTACKING:
			# Damage the player
			if body.has_method("take_damage"):
				body.take_damage(1)

		EnemyState.IDLE:
			# Determine kick direction based on which side the player hit
			direction = 1 if body.global_position.x < global_position.x else -1
			_update_raycasts_and_flip()
			
			if sprite.sprite_frames.has_animation("shell_wall_hit"):
				sprite.play("shell_wall_hit")
			
			transition_to_state(EnemyState.ATTACKING)

# =========================================================
# HELPERS
# =========================================================

func flip_direction() -> void:
	direction *= -1
	_update_raycasts_and_flip()

func _update_raycasts_and_flip() -> void:
	sprite.flip_h = (direction > 0)
	wall_checker.target_position.x = abs(wall_checker.target_position.x) * direction
	ledge_checker.position.x = abs(ledge_checker.position.x) * direction
	wall_checker.force_raycast_update()
	ledge_checker.force_raycast_update()

func _on_animation_finished() -> void:
	if current_state == EnemyState.DYING and sprite.animation == "shell_top_hit":
		queue_free()

func _spawn_flying_body() -> void:
	var body_debris = Sprite2D.new()
	body_debris.texture = naked_body_texture if naked_body_texture else preload("uid://bvdo266dk8xgp")
	body_debris.global_position = global_position
	body_debris.flip_h = sprite.flip_h
	get_parent().add_child(body_debris)

	# Fling the naked body up and backward in an arc
	var tween = create_tween().set_parallel(true)
	var fling_dir = -direction
	
	tween.tween_property(body_debris, "position:x", body_debris.position.x + (fling_dir * 50.0), 0.6)
	tween.tween_property(body_debris, "position:y", body_debris.position.y - 35.0, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.chain().tween_property(body_debris, "position:y", body_debris.position.y + 100.0, 0.35).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(body_debris, "modulate:a", 0.0, 0.6)
	tween.chain().tween_callback(body_debris.queue_free)
