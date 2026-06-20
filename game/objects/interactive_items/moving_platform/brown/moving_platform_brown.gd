@tool # This allows the script to run inside the Godot Editor!
extends Path2D

@export var chain_link_scene: PackedScene 
@export var link_spacing: float = 8.0
@export var speed: float = .007

var direction = 1
var is_player_on = false
var moving = false

@onready var path_follow: PathFollow2D = $PathFollow2D
@onready var chain_container: Node2D = $ChainContainer
@onready var platform_brown:PlatformBrown = $PathFollow2D/PlatformBrown

func _ready() -> void:
	# If we are actually playing the game, generate the chain
	if not Engine.is_editor_hint():
		if platform_brown:
			platform_brown.is_player_on.connect(update_is_player_on_status)
		generate_chain()

func _process(_delta: float) -> void:
	var is_moving = false
	# Move the saw (Only during actual gameplay, not in the editor)
	if not Engine.is_editor_hint() and path_follow:
		
		if is_player_on and not (path_follow.progress_ratio >= 1.0):
			direction = 1
			is_moving = true
		
		if not is_player_on and not (path_follow.progress_ratio <= 0.0):
			direction = -1
			is_moving = true
		
		if is_moving:
			path_follow.progress_ratio += speed * direction
			platform_brown.is_device_on = true
		else:
			platform_brown.is_device_on = false

# This built-in Godot function triggers whenever the Curve2D path changes in the editor
func _draw() -> void:
	if Engine.is_editor_hint():
		# This clears old links and updates the chain preview while you draw
		generate_chain()

func generate_chain() -> void:
	# Clear existing links first to avoid stacking duplicates
	if has_node("ChainContainer"):
		for child in $ChainContainer.get_children():
			child.queue_free()
	else:
		return
		
	if not chain_link_scene:
		return
		
	var path_length = curve.get_baked_length()
	if path_length < link_spacing:
		return
		
	var number_of_links = floor(path_length / link_spacing)
	
	for i in range(number_of_links):
		var current_distance = i * link_spacing
		var link_pos: Vector2 = curve.sample_baked(current_distance)
		var next_pos: Vector2 = curve.sample_baked(current_distance + 1.0)
		var link_angle: float = (next_pos - link_pos).angle()
		
		var link = chain_link_scene.instantiate() as Node2D
		$ChainContainer.add_child(link)
		link.position = link_pos
		link.rotation = link_angle
		
func update_is_player_on_status(value) -> void:
	is_player_on = value
