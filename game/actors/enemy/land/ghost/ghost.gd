extends EnemyBase

@onready var wall_checker: RayCast2D = $WallChecker
@onready var ledge_checker: RayCast2D = $LedgeChecker
@onready var head_hurtbox: Area2D = $HurtBox
@onready var hit_box: Area2D = $HitBox
@onready var phase_timer: Timer = $PhaseTimer

var is_visible:= true

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	phase_timer.wait_time = randf_range(1.0, 2.0)
	phase_timer.start()
	transition_to_state(EnemyState.PATROL)

# Patrol State
func enter_patrol_state() -> void:
	velocity.x = direction * speed
	sprite.play("run")

func update_patrol_state(delta: float) -> void:
	apply_gravity(delta)

	if wall_checker.is_colliding() or not ledge_checker.is_colliding():
		flip_direction()
		return

	velocity.x = direction * speed
	#sprite.play("run")
	move_and_slide()

# Dying State
func enter_dying_state() -> void:
	head_hurtbox.set_deferred("monitoring", false)
	hit_box.collision_layer = 1 << 5  # Layer 3
	super.enter_dying_state()
	if sprite.sprite_frames.has_animation("hit"):
		sprite.play("hit")

func _on_animation_finished() -> void:
	if sprite.animation == "disappear":
		head_hurtbox.set_deferred("monitoring", false)
		sprite.visible = false
		hit_box.collision_layer = 1 << 5  
		head_hurtbox.collision_layer = 1 << 5
	if sprite.animation == "appear": 
		sprite.play('run')
		hit_box.collision_layer = 1 << 2
		await get_tree().create_timer(.2).timeout
		head_hurtbox.set_deferred("monitoring", true)
		head_hurtbox.collision_layer = 1 << 3

func flip_direction() -> void:
	direction *= -1
	sprite.flip_h = (direction > 0)

	wall_checker.target_position.x *= -1
	ledge_checker.position.x *= -1

	wall_checker.force_raycast_update()
	ledge_checker.force_raycast_update()
	
func _on_phase_timer_timeout() -> void:
	_toggle_visiblity()
	
func _toggle_visiblity():
	if is_visible:
		sprite.play('disappear')
		is_visible = false
	else:
		sprite.visible = true
		sprite.play('appear')
		is_visible = true

func _on_hurt_box_body_entered(body: Node2D) -> void:
	handle_player_contact(body)
