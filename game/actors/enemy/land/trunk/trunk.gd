extends CharacterBody2D

enum EnemyState { PATROL, ATTACKING, IDLE, DYING }

@export var speed: float = 60.0
@export var gravity: float = 980.0
@export var bullet_scene: PackedScene

var current_state: EnemyState = EnemyState.PATROL
var direction: int = -1 # 1 = right, -1 = left

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var mouth_marker: Marker2D = $MouthMarker
@onready var hit_box: Area2D = $HitBox
@onready var hurt_box: Area2D = $HurtBox
@onready var wall_checker: RayCast2D = $WallChecker
@onready var ledge_checker: RayCast2D = $LedgeChecker
@onready var player_checker: RayCast2D = $PlayerChecker
@onready var shoot_timer: Timer = $ShootTimer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	transition_to_state(EnemyState.PATROL)

func _physics_process(delta: float) -> void:
	match current_state:
		EnemyState.PATROL:
			update_patrol_state(delta)
		EnemyState.IDLE:
			update_idle_state(delta)
		EnemyState.ATTACKING:
			update_attacking_state(delta)
		EnemyState.DYING:
			update_dying_state(delta)

func transition_to_state(new_state: EnemyState) -> void:
	if current_state == new_state:
		return

	current_state = new_state

	match current_state:
		EnemyState.PATROL:
			enter_patrol_state()
		EnemyState.IDLE:
			enter_idle_state()
		EnemyState.ATTACKING:
			enter_attacking_state()
		EnemyState.DYING:
			enter_dying_state()

func enter_patrol_state() -> void:
	velocity.x = direction * speed
	sprite.play("run")

func enter_idle_state() -> void:
	velocity.x = 0.0
	sprite.play("idle")

func enter_attacking_state() -> void:
	velocity.x = 0.0
	sprite.play("attack")

func enter_dying_state() -> void:
	velocity.x = 0.0

func update_patrol_state(delta: float) -> void:
	apply_gravity(delta)

	if wall_checker.is_colliding() or not ledge_checker.is_colliding():
		transition_to_state(EnemyState.IDLE)
		return

	velocity.x = direction * speed
	sprite.play("run")
	move_and_slide()

func update_idle_state(delta: float) -> void:
	apply_gravity(delta)
	velocity.x = 0.0
	move_and_slide()

func update_attacking_state(delta: float) -> void:
	apply_gravity(delta)
	velocity.x = 0.0
	move_and_slide()

func update_dying_state(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func _on_shoot_timer_timeout() -> void:
	if is_player_in_front():
		shoot()

func is_player_in_front() -> bool:
	if player_checker.is_colliding():
		var collider = player_checker.get_collider()
		if collider.is_in_group("player"):
			return true
	return false

func start_idle() -> void:
	transition_to_state(EnemyState.IDLE)

func start_attacking() -> void:
	transition_to_state(EnemyState.ATTACKING)

func _on_animation_finished() -> void:
	if current_state == EnemyState.IDLE and sprite.animation == "idle":
		flip_direction()
		transition_to_state(EnemyState.PATROL)

func flip_direction() -> void:
	direction *= -1
	sprite.flip_h = (direction > 0)

	wall_checker.target_position.x *= -1
	ledge_checker.position.x *= -1
	player_checker.position.x *= -1

	wall_checker.force_raycast_update()
	ledge_checker.force_raycast_update()
	player_checker.force_raycast_update()

func shoot() -> void:
	print("shoot")
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	bullet.global_position = mouth_marker.global_position
	bullet.direction = Vector2.RIGHT.rotated(rotation)
	get_tree().current_scene.add_child(bullet)
