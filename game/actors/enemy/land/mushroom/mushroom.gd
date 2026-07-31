extends CharacterBody2D

enum EnemyState { PATROL, IDLE, DYING }

@export var speed: float = 60.0
@export var gravity: float = 980.0

var current_state: EnemyState = EnemyState.PATROL
var direction: int = -1 # 1 = right, -1 = left

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_checker: RayCast2D = $WallChecker
@onready var ledge_checker: RayCast2D = $LedgeChecker
@onready var head_hurtbox: Area2D = $HeadHurtbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("run")

func _physics_process(delta: float) -> void:
	# If dying, bypass terrain and handle arc manually
	if current_state == EnemyState.DYING:
		velocity.y += gravity * delta  # Gravity accelerates fall speed down
		position += velocity * delta   # Move position through walls/floors
		return

	# Normal physics logic below...
	if not is_on_floor():
		velocity.y += gravity * delta

	match current_state:
		EnemyState.PATROL:
			if wall_checker.is_colliding() or not ledge_checker.is_colliding():
				start_idle()
			else:
				velocity.x = direction * speed
				sprite.play("run")

		EnemyState.IDLE:
			velocity.x = 0.0

	move_and_slide()
func start_idle() -> void:
	current_state = EnemyState.IDLE
	velocity.x = 0.0
	sprite.play("idle")

func _on_animation_finished() -> void:
	if current_state == EnemyState.IDLE and sprite.animation == "idle":
		flip_direction()
		current_state = EnemyState.PATROL
		# Set movement immediately so physics tick moves away from the trigger
		velocity.x = direction * speed

func flip_direction() -> void:
	direction *= -1
	sprite.flip_h = (direction > 0)
	
	# Flip RayCast positions/directions
	wall_checker.target_position.x *= -1
	ledge_checker.position.x *= -1
	
	# Force RayCasts to update their collision state immediately, 
	# rather than waiting for the next physics frame
	wall_checker.force_raycast_update()
	ledge_checker.force_raycast_update()

# --- HIT / DEATH LOGIC ---

func _on_head_hurtbox_body_entered(body: Node2D) -> void:
	if current_state == EnemyState.DYING or not body.is_in_group("player"):
		return
	
	# Default bounce velocity
	var bounce_force: float = -500.0
	
	# Make the player bounce off the enemy's head
	if body.has_method("bounce"):
		body.bounce()
		# If player script exports/defines JUMP_VELOCITY or similar:
		if "JUMP_VELOCITY" in body:
			bounce_force = body.JUMP_VELOCITY
	elif "velocity" in body:
		body.velocity.y = bounce_force
		if "JUMP_VELOCITY" in body:
			bounce_force = body.JUMP_VELOCITY

	die_from_hit(body.global_position, bounce_force)


func die_from_hit(player_position: Vector2, player_jump_force: float) -> void:
	audio_stream_player_2d.play()
	current_state = EnemyState.DYING

	# 1. Disable collisions completely
	collision_shape.set_deferred("disabled", true)
	head_hurtbox.set_deferred("monitoring", false)

	# 2. Play hit animation
	if sprite.sprite_frames.has_animation("hit"):
		sprite.play("hit")

	# 3. Calculate direction away from player
	var hit_direction: float = sign(global_position.x - player_position.x)
	if hit_direction == 0:
		hit_direction = 1.0

	# Ensure jump force is UPWARDS (negative Y in Godot)
	# abs() ensures we always launch upward regardless of player jump variable sign
	var upward_pop: float = -abs(player_jump_force) * 0.5
	if upward_pop == 0:
		upward_pop = -200.0 # Fallback pop force if player jump was 0
		
	velocity.y = upward_pop
	velocity.x = hit_direction * 80.0

	# 4. Flip upside down
	var target_rotation: float = rotation + (deg_to_rad(180.0) * hit_direction)
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation", target_rotation, 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

	# 5. Safety fallback cleanup
	get_tree().create_timer(1.0).timeout.connect(queue_free)
