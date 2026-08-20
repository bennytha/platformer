extends EnemyBase

@export var bullet_scene: PackedScene
@export var attack_interval: float = .4

@export_group("Horizontal Patrol")
@export var patrol_distance: float = 60.0     ## Max distance from origin in pixels
@export var patrol_duration: float = 2.5       ## Seconds to cross one full direction

@export_group("Vertical Bobbing")
@export var hover_amplitude: float = 14.0      ## Pixels up/down
@export var hover_frequency: float = 3.2       ## Speed of vertical cycle
@export var secondary_hover_amp: float = 4.0

@onready var mouth_marker: Marker2D = $MouthMarker
@onready var shoot_timer: Timer = $ShootTimer
@onready var player_detection_area: Area2D = $PlayerDetectionArea
@onready var hit_box: Area2D = $HitBox
@onready var head_hurtbox: Area2D = $HurtBox

var origin_x: float
var patrol_progress: float = 0.0 # Normalized range: -1.0 (left) to 1.0 (right)
var hover_time: float = 0.0
var previous_hover_offset: float = 0.0

func _ready() -> void:
	# Record initial position as anchor origin
	origin_x = global_position.x
	
	# Randomize starting wave offsets so multiple bees don't move in sync
	hover_time = randf_range(0.0, TAU)
	patrol_progress = randf_range(-0.5, 0.5)
	previous_hover_offset = _get_hover_offset()

	sprite.animation_finished.connect(_on_animation_finished)
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	transition_to_state(EnemyState.PATROL)

# Patrol State
func enter_patrol_state() -> void:
	velocity.x = direction * speed
	sprite.play("fly")

func update_patrol_state(delta: float) -> void:
	_update_flight(delta)

	if is_player_near_by() and shoot_timer.is_stopped():
		transition_to_state(EnemyState.ATTACKING)

# Attacking State
func enter_attacking_state() -> void:
	if is_player_near_by():
		shoot()
		shoot_timer.start(attack_interval)

func update_attacking_state(delta: float) -> void:
	_update_flight(delta)

func enter_dying_state() -> void:
	shoot_timer.stop()
	head_hurtbox.set_deferred("monitoring", false)
	hit_box.set_deferred("monitoring", false)
	hit_box.collision_layer = 1 << 5  # Layer 3
	super.enter_dying_state()
	if sprite.sprite_frames.has_animation("hit"):
		sprite.play("hit")

# -------------------------------------
func _update_flight(delta: float) -> void:
	hover_time += delta
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

	if current_state == EnemyState.PATROL:
		sprite.play("fly")

func _get_hover_offset() -> float:
	return (
		sin(hover_time * hover_frequency) * hover_amplitude
		+ sin(hover_time * hover_frequency * 2.3) * secondary_hover_amp
	)

func _on_shoot_timer_timeout() -> void:
	if current_state == EnemyState.DYING:
		return

	if is_player_near_by() and current_state != EnemyState.ATTACKING:
		transition_to_state(EnemyState.ATTACKING)
	elif current_state == EnemyState.ATTACKING:
		shoot()
		shoot_timer.start(attack_interval)

func is_player_near_by() -> bool:
	for body in player_detection_area.get_overlapping_bodies():
		if body != null and body.is_in_group("player"):
			return true
	return false

func _on_animation_finished() -> void:
	if current_state == EnemyState.ATTACKING and sprite.animation == "attack":
		transition_to_state(EnemyState.PATROL)

func shoot() -> void:
	sprite.play("attack")
	spawn_bullet()

func spawn_bullet() -> void:
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	bullet.global_position = mouth_marker.global_position
	bullet.direction = Vector2.DOWN
	get_parent().add_child(bullet)


func _on_hurt_box_body_entered(body: Node2D) -> void:
	handle_player_contact(body)
