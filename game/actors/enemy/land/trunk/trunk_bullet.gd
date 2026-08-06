extends Area2D

@export var speed: float = 400.0
@export var broken_texture: Texture2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var debris_container: Node2D = $DebrisContainer

var direction: Vector2 = Vector2.RIGHT
var is_broken: bool = false

func _ready() -> void:
	sprite_2d.flip_h = direction != Vector2.RIGHT

func _physics_process(delta: float) -> void:
	if not is_broken:
		position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if is_broken:
		return
	if body != null and (body.is_in_group("player") or body.is_in_group("world")):
		call_deferred("break_bullet")

func break_bullet() -> void:
	is_broken = true
	collision_shape_2d.set_deferred("disabled", true)
	sprite_2d.visible = false
	var knockback_dir: Vector2 = -direction.normalized()
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
		
		debris_container.add_child(debris)
		
		# Base knockback going backward + upward force + slight random spread
		var impulse = knockback_dir * randf_range(80.0, 140.0)
		impulse.y -= randf_range(60.0, 100.0) # Adds upward bounce
		impulse.x += randf_range(-20.0, 20.0)  # Slight spread between pieces
		
		# Scatter debris outwards
		#var impulse = Vector2(randf_range(-60, 60), randf_range(-120, -40))
		debris.apply_central_impulse(impulse)
		debris.apply_torque_impulse(randf_range(-200.0, 200.0))

	await get_tree().create_timer(1.0).timeout
	queue_free()
