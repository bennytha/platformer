@tool
extends Node2D

@export_category("Path Setup")
@export var end_point: Vector2 = Vector2(0, 100):
	set(val):
		end_point = val
		queue_redraw()

@export_category("Movement Settings")
## Speed of the swing/rotation (in radians per second).
@export var speed: float = 2.0
## Max angle for standard swinging (e.g., 70 degrees). Ignored if it starts circling.
@export var max_swing_angle: float = 70.0
@export var prediction_distance: float = 25.0

@onready var chain_drawer: Line2D = $ChainDrawer
@onready var spiked_ball: StaticBody2D = $SpikedBall
@onready var predictor: RayCast2D = $Predictor

# Internal State
var current_angle: float = 0.0
var length: float = 0.0
var direction: int = 1 # 1 = Clockwise/Right, -1 = Counter-Clockwise/Left
var is_circling: bool = false
var time_passed: float = 0.0

func _ready() -> void:
	# Calculate initial math based on your custom start/end points
	length = end_point.length()
	current_angle = end_point.angle()
	
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		if chain_drawer and spiked_ball:
			update_chain_and_ball(end_point)
		return
		
	if is_circling:
		current_angle += speed * direction * delta
	else:
		time_passed += delta * speed * direction
		var max_rad = deg_to_rad(max_swing_angle)
		current_angle = (sin(time_passed) * max_rad) + (PI / 2)
	
	var target_offset = Vector2.from_angle(current_angle) * length
	check_wall_prediction(target_offset)
	update_chain_and_ball(target_offset)
	
func update_chain_and_ball(ball_offset: Vector2) -> void:
	spiked_ball.position = ball_offset
	
	# Draw the chain from origin (0,0) to the ball
	chain_drawer.clear_points()
	chain_drawer.add_point(Vector2.ZERO)
	chain_drawer.add_point(ball_offset)

func check_wall_prediction(current_offset: Vector2) -> void:
	# Position the raycast at the center of the ball
	predictor.position = current_offset
	
	# Point the raycast in the direction of travel (tangent to the circle)
	var travel_angle = current_angle + (PI / 2 * direction)
	predictor.target_position = Vector2.from_angle(travel_angle) * prediction_distance
	
	# Force an immediate raycast update
	predictor.force_raycast_update()
	
	if predictor.is_colliding():
		# It's about to hit a wall! Turn around immediately.
		direction *= -1

# Optional: Draw lines in the editor viewport to see your start/end settings easily
func _draw() -> void:
	if Engine.is_editor_hint():
		draw_line(Vector2.ZERO, end_point, Color.RED, 2.0)
		draw_circle(Vector2.ZERO, 5.0, Color.GREEN)
