extends EnemyBase

@onready var head_hurtbox: Area2D = $HurtBox
@onready var hit_box: Area2D = $HitBox
@onready var idle_timer: Timer = $IdleTimer
@onready var attack_timer: Timer = $AttackTimer

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	transition_to_state(EnemyState.IDLE)

# Idle State
func enter_idle_state() -> void:
	velocity.x = 0.0
	sprite.play("idle")
	idle_timer.start()

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
	if sprite.animation == "spikes_out":
		sprite.play('attack')
		attack_timer.start()
		_toggle_hit_and_hurt_boxes(true)
	if sprite.animation == "spikes_in":
		sprite.play('idle')
		idle_timer.start()
		_toggle_hit_and_hurt_boxes(false)

func flip_direction() -> void:
	direction *= -1
	sprite.flip_h = (direction > 0)

func _toggle_hit_and_hurt_boxes(is_attacking:bool):
	head_hurtbox.set_deferred("monitoring", not is_attacking)
	if is_attacking:
		hit_box.collision_layer = GameConstants.DAMAGE_PLAYER_LAYER	
		head_hurtbox.collision_layer = GameConstants.NON_PLAYER_INTERACTION_LAYER
	else:
		hit_box.collision_layer = GameConstants.NON_PLAYER_INTERACTION_LAYER
		head_hurtbox.collision_layer = GameConstants.PLAYER_INTERACTION_LAYER

func _on_player_checker_l_body_entered(_body: Node2D) -> void:
	if direction == 1:
		flip_direction()

func _on_player_checker_r_body_entered(_body: Node2D) -> void:
	if direction != 1:
		flip_direction()


func _on_idle_timer_timeout() -> void:
	print('idle_timer_timeout')
	sprite.play('spikes_out')


func _on_attack_timer_timeout() -> void:
	print('attack_timer_timeout')
	sprite.play('spikes_in')


func _on_hurt_box_body_entered(body: Node2D) -> void:
	handle_player_contact(body)
