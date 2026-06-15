extends Area2D

# Vector direction and strength (e.g., Vector2(-300, 0) pushes hard to the left)
# Vector2(0, -500) creates a massive draft pushing the player upwards
@export var wind_force: Vector2 = Vector2(-150, 0) 

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	# Check if the body entering has our composition setup
	if body.has_node("VelocityComponent"):
		var velocity_comp = body.get_node("VelocityComponent")
		velocity_comp.environmental_force = wind_force

func _on_body_exited(body: Node2D) -> void:
	if body.has_node("VelocityComponent"):
		var velocity_comp = body.get_node("VelocityComponent")
		# Reset the force to zero when leaving the wind zone
		velocity_comp.environmental_force = Vector2.ZERO
