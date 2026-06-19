@tool
extends Node2D

enum MovementMode { LOOP, BACK_AND_FORTH }

@export_category("Path Configuration")
## Input your path positions here as local coordinates relative to this node.
@export var waypoints: Array[Vector2] = [Vector2(0,0), Vector2(200,0), Vector2(200,200), Vector2(0,200)]:
	set(value):
		waypoints = value
		queue_redraw() # Tells Godot to redraw the path lines in the editor
		_update_editor_position()

@export_category("Editor Debugging")
## Controls which waypoint index the spike head snaps to in the editor viewport (0-indexed).
@export var editor_preview_index: int = 0:
	set(value):
		editor_preview_index = value
		if Engine.is_editor_hint() and is_inside_tree():
			_update_editor_position()

@export_category("Movement Settings")
@export var movement_mode: MovementMode = MovementMode.LOOP
@export var speed: float = 200.0
@export var pause_duration: float = 1.0
@export var start_speed: float = 60.0
@export var ramp_time: float = 0.4 

@onready var spike_head: StaticBody2D = $SpikeHead
@onready var timer: Timer = $Timer

var current_marker_index: int = 0
var next_marker_index: int = 1

var is_paused: bool = false
var moving_forward: bool = true
var sprite: AnimatedSprite2D = null
var current_speed: float = 0.0
var accelerating: bool = false
var _acceleration: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if spike_head.has_node("AnimatedSprite2D"):
		sprite = spike_head.get_node("AnimatedSprite2D") as AnimatedSprite2D

	if waypoints.size() < 2:
		set_process(false)
		push_warning("MovingRockWaypoints needs at least 2 positions in the waypoints array!")
		return

	timer.wait_time = pause_duration
	timer.timeout.connect(_on_timer_timeout)
	
	# Start precisely at the first waypoint's global position
	spike_head.global_position = to_global(waypoints[0])
	current_speed = speed
	if sprite:
		sprite.play("default")

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if is_paused or waypoints.size() < 2:
		return

	# Calculate targets using global coordinates
	var target_global_pos = to_global(waypoints[next_marker_index])
	var current_global_pos = spike_head.global_position

	var direction_vector = target_global_pos - current_global_pos
	var distance_to_target = direction_vector.length()
	var movement_direction = direction_vector.normalized()

	var movement_step = current_speed * delta

	if distance_to_target <= movement_step:
		spike_head.global_position = target_global_pos
		trigger_hit_sequence(movement_direction)
		update_next_marker()
	else:
		spike_head.global_position += movement_direction * movement_step

func update_next_marker() -> void:
	var total_markers = waypoints.size()
	current_marker_index = next_marker_index

	if movement_mode == MovementMode.LOOP:
		next_marker_index = (next_marker_index + 1) % total_markers
	else: # BACK_AND_FORTH
		if moving_forward:
			if next_marker_index == total_markers - 1:
				moving_forward = false
				next_marker_index -= 1
			else:
				next_marker_index += 1
		else:
			if next_marker_index == 0:
				moving_forward = true
				next_marker_index += 1
			else:
				next_marker_index -= 1

func trigger_hit_sequence(direction: Vector2) -> void:
	is_paused = true
	var anim_to_play = "default"

	if abs(direction.x) > abs(direction.y):
		anim_to_play = "hit_right" if direction.x > 0 else "hit_left"
	else:
		anim_to_play = "hit_bottom" if direction.y > 0 else "hit_top"

	if sprite:
		sprite.play(anim_to_play)
		await sprite.animation_finished
		sprite.play("default")

	timer.start()

func _on_timer_timeout() -> void:
	is_paused = false
	if ramp_time > 0.0:
		current_speed = start_speed
		_acceleration = (speed - start_speed) / ramp_time
		accelerating = true
	else:
		current_speed = speed
		accelerating = false

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): 
		return
		
	if accelerating:
		current_speed += _acceleration * delta
		if _acceleration > 0.0 and current_speed >= speed:
			current_speed = speed
			accelerating = false
		elif _acceleration < 0.0 and current_speed <= speed:
			current_speed = speed
			accelerating = false

## Draw the path in the editor viewport for easier debugging
func _draw() -> void:
	if not Engine.is_editor_hint() or waypoints.size() < 2:
		return
		
	var line_color = Color(1, 0.3, 0.3, 0.6) # Translucent red line
	var point_color = Color(1, 1, 0, 0.8)     # Yellow dots for points
	
	# Draw lines connecting the waypoints
	for i in range(waypoints.size() - 1):
		draw_line(waypoints[i], waypoints[i+1], line_color, 2.0)
		draw_circle(waypoints[i], 4.0, point_color)
	
	# Draw final point dot
	draw_circle(waypoints[-1], 4.0, point_color)
	
	# If looping, draw closing line
	if movement_mode == MovementMode.LOOP:
		draw_line(waypoints[-1], waypoints[0], line_color, 2.0)

## Editor visual aid to check position snap
func _update_editor_position() -> void:
	var rock_head = get_node_or_null("SpikeHead")
	if rock_head and waypoints.size() > 0:
		var target_idx = clampi(editor_preview_index, 0, waypoints.size() - 1)
		rock_head.position = waypoints[target_idx]
