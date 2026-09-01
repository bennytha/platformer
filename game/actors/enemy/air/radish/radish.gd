extends EnemyBase

@export var attack_interval: float = .4
@export var broken_texture: Texture2D

@export_group("Horizontal Patrol")
@export var patrol_distance: float = 60.0     ## Max distance from origin in pixels
@export var patrol_duration: float = 2.5       ## Seconds to cross one full direction

@export_group("Vertical Bobbing")
@export var hover_amplitude: float = 14.0      ## Pixels up/down
@export var hover_frequency: float = 3.2       ## Speed of vertical cycle
@export var secondary_hover_amp: float = 4.0

@onready var wall_checker: RayCast2D = $WallChecker
@onready var ledge_checker: RayCast2D = $LedgeChecker
@onready var hit_box: Area2D = $HitBox
@onready var head_hurtbox: Area2D = $HurtBox
@onready var debris_container: Node2D = $DebrisContainer

var origin_x: float
var patrol_progress: float = 0.0 # Normalized range: -1.0 (left) to 1.0 (right)
var hover_time: float = 0.0
var previous_hover_offset: float = 0.0
var can_fly := true

func _ready() -> void:
	# Record initial position as anchor origin
	origin_x = global_position.x
	
	# Randomize starting wave offsets so multiple bees don't move in sync
	hover_time = randf_range(0.0, TAU)
	patrol_progress = randf_range(-0.5, 0.5)
	previous_hover_offset = _get_hover_offset()
	
	sprite.animation_finished.connect(_on_animation_finished)
	transition_to_state(EnemyState.AIR_PATROL)

# Air patrol State
func enter_air_patrol_state() -> void:
	velocity.x = direction * speed
	sprite.flip_h = direction > 0
	sprite.play("fly")

func update_air_patrol_state(delta: float) -> void:
	_update_flight(delta)

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
	sprite.play("idle")

func update_idle_state(delta: float) -> void:
	apply_gravity(delta)
	velocity.x = 0.0
	move_and_slide()

func enter_dying_state() -> void:
	head_hurtbox.set_deferred("monitoring", false)
	hit_box.set_deferred("monitoring", false)
	hit_box.collision_layer = 1 << 5  # Layer 3
	super.enter_dying_state()
	if sprite.sprite_frames.has_animation("hit"):
		sprite.play("hit")

# -------------------------------------
func _update_flight(delta: float) -> void:
	hover_time += delta
	var previous_direction: int = direction
	var sweep_speed: float = 2.0 / max(patrol_duration, 0.01)
	patrol_progress += direction * sweep_speed * delta

	if patrol_progress >= 1.0:
		patrol_progress = 1.0
		direction = -1
	elif patrol_progress <= -1.0:
		patrol_progress = -1.0
		direction = 1

	var eased_factor: float = sin(patrol_progress * (PI * 0.5))
	var target_x: float = origin_x + eased_factor * patrol_distance
	var hover_offset: float = _get_hover_offset()

	velocity.x = (target_x - global_position.x) / max(delta, 0.001)
	velocity.y = (hover_offset - previous_hover_offset) / max(delta, 0.001)
	previous_hover_offset = hover_offset
	move_and_slide()

	if is_on_wall():
		direction *= -1
		patrol_progress = clamp(patrol_progress, -0.95, 0.95)

	if direction != previous_direction:
		sprite.flip_h = direction > 0

	if current_state == EnemyState.PATROL:
		sprite.play("fly")

func _get_hover_offset() -> float:
	return (
		sin(hover_time * hover_frequency) * hover_amplitude
		+ sin(hover_time * hover_frequency * 2.3) * secondary_hover_amp
	)

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if not body.is_in_group('player'):
		return
	if can_fly:
		can_fly = false
		break_leaf()
		sprite.play('hit')
		handle_player_contact_locally(body)
		await sprite.animation_finished
		transition_to_state(EnemyState.IDLE)
		
	else:
		head_hurtbox.set_deferred("monitoring", false)
		hit_box.set_deferred("monitoring", false)
		handle_player_contact(body)

func break_leaf() -> void:
	var knockback_dir: Vector2 = Vector2.ZERO
	var debry_1:RigidBody2D = null
	var debry_2:RigidBody2D = null
	# Define regions for left and right halves of the texture
	var regions: Array[Rect2] = [
		Rect2(0, 0, 16, 16),  # First broken piece
		Rect2(16, 0, 16, 16)  # Second broken piece
	]
	
	# Spawn two falling debris pieces
	for i in range(2):
		var debris = RigidBody2D.new()
		var sprite = Sprite2D.new()
		var collision = CollisionShape2D.new()
		var rectangle_shape = RectangleShape2D.new()
		
		debris.gravity_scale = .5
		debris.collision_layer = 1 << 4  # Layer 3
		debris.collision_mask = 1 << 1   # Mask 2
		
		rectangle_shape.size = Vector2(6.0,6.0)
		collision.shape = rectangle_shape
		
		var atlas = AtlasTexture.new()
		atlas.atlas = broken_texture 
		atlas.region = regions[i]
		sprite.texture = atlas
		
		debris.position = Vector2(0, (i * 8) - 4)
		debris.add_child(sprite)
		debris.add_child(collision)
		
		if i == 1:
			debry_1 = debris
		else:
			debry_2 = debris
		
		debris_container.call_deferred("add_child", debris)
		
		var impulse = knockback_dir * randf_range(80.0, 140.0)
		impulse.y -= randf_range(60.0, 100.0) # Adds upward bounce
		impulse.x += randf_range(-20.0, 20.0)  # Slight spread between pieces
		
		# Scatter debris outwards
		#var impulse = Vector2(randf_range(-60, 60), randf_range(-120, -40))
		debris.apply_central_impulse(impulse)
		debris.apply_torque_impulse(randf_range(-200.0, 200.0))

	await get_tree().create_timer(1.0).timeout
	debry_1.queue_free()
	debry_2.queue_free()

func _on_animation_finished() -> void:
	if current_state == EnemyState.IDLE and sprite.animation == "idle":
		flip_direction()
		transition_to_state(EnemyState.PATROL)

func flip_direction() -> void:
	direction *= -1
	sprite.flip_h = (direction > 0)

	var wall_offset: float = abs(wall_checker.target_position.x)
	var ledge_offset: float = abs(ledge_checker.position.x)
	wall_checker.target_position.x = wall_offset if direction > 0 else -wall_offset
	ledge_checker.position.x = ledge_offset if direction > 0 else -ledge_offset

	wall_checker.force_raycast_update()
	ledge_checker.force_raycast_update()

func handle_player_contact_locally(body: Node2D) -> void:
	var bounce_force: float = -500.0

	if body.has_method("bounce"):
		body.bounce()
		if "JUMP_VELOCITY" in body:
			bounce_force = body.JUMP_VELOCITY
	elif "velocity" in body:
		body.velocity.y = bounce_force
		if "JUMP_VELOCITY" in body:
			bounce_force = body.JUMP_VELOCITY

	die_from_hit_locally(body.global_position, bounce_force)

func die_from_hit_locally(player_position: Vector2, player_jump_force: float) -> void:
	var hit_direction: float = sign(global_position.x - player_position.x)
	if hit_direction == 0:
		hit_direction = 1.0

	var upward_pop: float = -abs(player_jump_force) * 0.5
	if upward_pop == 0:
		upward_pop = -200.0

	velocity.y = upward_pop
	velocity.x = hit_direction * death_force
# --------------------------------------------


func _on_hit_box_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var knockback_dir: float = sign(global_position.x - body.global_position.x)
	if knockback_dir == 0:
		knockback_dir = 1.0

	direction = int(knockback_dir)
	#sprite.flip_h = direction > 0
	velocity.x = knockback_dir * 140.0
	velocity.y = -80.0
	move_and_slide()
