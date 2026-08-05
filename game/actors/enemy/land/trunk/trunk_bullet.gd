extends Area2D

@export var speed: float = 400.0
@export var broken_texture: Texture2D

var direction: Vector2 = Vector2.RIGHT
var is_broken: bool = false

func _physics_process(delta: float) -> void:
	if not is_broken:
		position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Check if the collision is on the world layer
	if not is_broken and body.is_in_group("player"):
		break_bullet()

func break_bullet() -> void:
	is_broken = true
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.visible = false

	# Spawn two falling debris pieces
	for i in range(2):
		var debris = RigidBody2D.new()
		var sprite = Sprite2D.new()
		var collision = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		
		circle_shape.radius = 4.0
		collision.shape = circle_shape
		sprite.texture = broken_texture
		
		# Offset texture slightly so each piece shows a different part if using a sprite sheet,
		# or just apply random rotation/impulse to separate them
		debris.position = Vector2(0, (i * 8) - 4) 
		
		debris.add_child(sprite)
		debris.add_child(collision)
		$DebrisContainer.add_child(debris)
		
		# Apply a slight horizontal/vertical bounce outwards
		var impulse = Vector2(randf_range(-50, 50), randf_range(-150, -50))
		debris.apply_central_impulse(impulse)

	# Wait 1 second before deleting the bullet node
	await get_tree().create_timer(1.0).timeout
	queue_free()
