extends EnemyBase

@export var flap_start_frame: int = 5
@export var flap_up_speed: float = 60.0

@onready var wall_checker: RayCast2D = $WallChecker
@onready var head_hurtbox: Area2D = $HurtBox
@onready var hit_box: Area2D = $HitBox

func _ready() -> void:
	transition_to_state(EnemyState.PATROL)

# Patrol State
func enter_patrol_state() -> void:
	velocity.x = direction * speed
	sprite.play("flying")

func update_patrol_state(_delta: float) -> void:
	if wall_checker.is_colliding():
		transition_to_state(EnemyState.IDLE)
		return

	velocity.x = direction * speed

	var frame_count: int = 9
	if sprite != null and sprite.sprite_frames != null and sprite.sprite_frames.has_animation("flying"):
		frame_count = sprite.sprite_frames.get_frame_count("flying")

	var current_frame: int = 0
	if sprite != null:
		current_frame = int(sprite.frame) % max(frame_count, 1)

	var up_frame_count: int = max(frame_count - flap_start_frame, 1)
	var down_frame_count: int = max(flap_start_frame, 1)
	var balanced_down_speed: float = flap_up_speed * float(up_frame_count) / float(down_frame_count)

	if current_frame >= flap_start_frame:
		velocity.y = -flap_up_speed
	else:
		velocity.y = balanced_down_speed
	move_and_slide()

# Idle State
func enter_idle_state() -> void:
	velocity.x = 0.0
	flip_direction()
	transition_to_state(EnemyState.PATROL)

# Dying State
func enter_dying_state() -> void:
	head_hurtbox.set_deferred("monitoring", false)
	hit_box.set_deferred("monitoring", false)
	hit_box.collision_layer = 1 << 5  # Layer 3
	super.enter_dying_state()
	if sprite.sprite_frames.has_animation("hit"):
		sprite.play("hit")

func flip_direction() -> void:
	direction *= -1
	sprite.flip_h = (direction > 0)

	wall_checker.target_position.x *= -1

	wall_checker.force_raycast_update()

func _on_hurt_box_body_entered(body: Node2D) -> void:
	handle_player_contact(body)
