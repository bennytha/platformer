extends RigidBody2D
@onready var detection_box: Area2D = $DetectionBox
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var item_data: ItemData

func _ready() -> void:
	detection_box.body_entered.connect(_on_body_entered)
	if gravity_scale == 0.0:
		collision_shape_2d.disabled = true
	
func _on_body_entered(body: CharacterBody2D) -> void:
	# Look for our InventoryComponent inside the body that collided with us
	if body.has_node("InventoryComponent"):
		var inventory = body.get_node("InventoryComponent") as InventoryComponent
		
		# Hand the resource over to the inventory component
		inventory.add_item(item_data)
		
		# Optional: Play an audio splash or spawn a visual particle effect here
		animated_sprite_2d.play("collected")
		await animated_sprite_2d.animation_finished
		# Delete the collectible from the world map
		queue_free() 
