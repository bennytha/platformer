extends StaticBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var area_collision = $Area2D/CollisionShape2D

# 1. Export the TSCN files directly instead of using internal template nodes
@export var block_top_scene: PackedScene
@export var block_bottom_scene: PackedScene

@export var impact_threshold: float = 300.0
var hit_count : int = 0

func _ready():
	animated_sprite.play("idle")

func handle_hit(collider_global_position: Vector2):
	hit_count += 1
	
	if hit_count == 1:
		var direction = (collider_global_position - global_position).normalized()
		
		if abs(direction.y) > abs(direction.x):
			animated_sprite.play("hit_vertical")
		else:
			animated_sprite.play("hit_horizontal")
			
		await animated_sprite.animation_finished
		animated_sprite.play("idle")
		
	elif hit_count >= 2:
		break_block()

func break_block():
	# Disable collisions safely during physics processing
	collision_shape.set_deferred("disabled", true)
	area_collision.set_deferred("disabled", true)
	animated_sprite.visible = false
	call_deferred("_deferred_break_block")

func _deferred_break_block():
	spawn_piece(block_top_scene, Vector2(0, -4))
	spawn_piece(block_bottom_scene, Vector2(0, 4))

	# Clean up the parent block
	await get_tree().create_timer(3.0).timeout
	queue_free()

func spawn_piece(piece_scene: PackedScene, offset: Vector2):
	if not piece_scene:
		push_warning("Piece scene missing on breaking block!")
		return
		
	# Instantiate a clean, fresh copy of the debris piece
	var piece = piece_scene.instantiate() as RigidBody2D
	
	# Add it to the parent first so global_position and physics work properly
	get_parent().add_child(piece)
	
	# Position it relative to this block's current position
	piece.global_position = global_position + offset

	# Apply physics forces
	var horizontal_force = randf_range(-70, 70)
	var vertical_force = -180 if offset.y < 0 else 140
	
	piece.linear_velocity = Vector2(horizontal_force, vertical_force)
	piece.angular_velocity = randf_range(-5, 5)

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player") and body.has_node("VelocityComponent"): 
		var velocity_comp = body.get_node("VelocityComponent")
		var velocity_history: Array[Vector2] = velocity_comp.velocity_history
		
		var max_velocity = Vector2.ZERO
		for vel in velocity_history:
			max_velocity.x = max(max_velocity.x, abs(vel.x))
			max_velocity.y = max(max_velocity.y, abs(vel.y))
		
		if max_velocity.length() >= impact_threshold:
			handle_hit(body.global_position)
