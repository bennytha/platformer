extends EnemyBase

@export var bullet_scene: PackedScene
@export var attack_interval: float = .45
@export var attack_shoot_frame: int = 5
@export var should_flip_direction:bool = false

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var mouth_marker: Marker2D = $MouthMarker
@onready var hit_box: Area2D = $HitBox
@onready var hurt_box: Area2D = $HurtBox
@onready var player_checker: RayCast2D = $PlayerChecker
@onready var shoot_timer: Timer = $ShootTimer

var should_spawn_bullet: bool = false

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_sprite_frame_changed)
	transition_to_state(EnemyState.IDLE)
	if should_flip_direction:
		flip_direction()

# Idle State
func enter_idle_state() -> void:
	velocity.x = 0.0
	sprite.play("idle")

func update_idle_state(delta: float) -> void:
	if is_player_in_front() and shoot_timer.is_stopped():
		transition_to_state(EnemyState.ATTACKING)
		return

# Attacking State
func enter_attacking_state() -> void:
	velocity.x = 0.0

	if is_player_in_front():
		shoot()
		shoot_timer.start(attack_interval)

func update_attacking_state(delta: float) -> void:
	apply_gravity(delta)
	velocity.x = 0.0
	move_and_slide()


func enter_dying_state() -> void:
	hurt_box.set_deferred("monitoring", false)
	hit_box.set_deferred("monitoring", false)
	hit_box.collision_layer = 1 << 5  # Layer 4
	super.enter_dying_state()
# -------------------------------------

func is_player_in_front() -> bool:
	player_checker.force_raycast_update()

	if player_checker.is_colliding():
		var collider = player_checker.get_collider()
		if collider != null and collider.is_in_group("player"):
			return true
	return false

func _on_animation_finished() -> void:
	if current_state == EnemyState.ATTACKING and sprite.animation == "attack":
		should_spawn_bullet = false
		transition_to_state(EnemyState.IDLE)

func _on_sprite_frame_changed() -> void:
	if current_state != EnemyState.ATTACKING:
		return
	if sprite.animation != "attack":
		return
	if should_spawn_bullet and sprite.frame == attack_shoot_frame:
		spawn_bullet()
		should_spawn_bullet = false

func shoot() -> void:
	sprite.play("attack")
	should_spawn_bullet = true

func spawn_bullet() -> void:
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	bullet.global_position = mouth_marker.global_position
	bullet.direction = Vector2.RIGHT * direction
	get_parent().add_child(bullet)

func flip_direction() -> void:
	direction *= -1
	sprite.flip_h = (direction > 0)

	player_checker.target_position.x *= -1
	mouth_marker.position.x *= -1

	player_checker.force_raycast_update()
	mouth_marker.force_update_transform()

func _on_hurt_box_body_entered(body: Node2D) -> void:
	handle_player_contact(body)
