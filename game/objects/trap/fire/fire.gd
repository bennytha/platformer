extends StaticBody2D
@onready var detection_box: Area2D = $DetectionBox
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_collision_shape_2d: CollisionShape2D = $HitBox/CollisionShape2D

const HIT_COOLDOWN: float = 0.5
const FIRE_DURATION: float = 1.0

func _ready() -> void:
	hitbox_collision_shape_2d.disabled = true
	detection_box.body_entered.connect(start_fire)
	
	
func start_fire(body:CharacterBody2D) -> void:
	if body.is_in_group('player'):
		animated_sprite_2d.play("hit")
		await get_tree().create_timer(HIT_COOLDOWN).timeout
		
		hitbox_collision_shape_2d.disabled = false
		animated_sprite_2d.play("on")
		await get_tree().create_timer(FIRE_DURATION).timeout

		hitbox_collision_shape_2d.disabled = true
		animated_sprite_2d.play("default")
	
