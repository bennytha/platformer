@tool # This allows the script to run inside the Godot Editor!
extends Path2D

@export var chain_link_scene: PackedScene 
@export var link_spacing: float = 8.0
@export var speed: float = 50

var path_length: float = 0.0
var direction:int = 1
var is_player_on:bool = false
var moving:bool = false

@onready var path_follow: PathFollow2D = $PathFollow2D
@onready var chain_container: Node2D = $ChainContainer
@onready var platform_brown:PlatformBrown = $PathFollow2D/PlatformBrown

func _ready() -> void:
	# If we are actually playing the game, generate the chain
	if not Engine.is_editor_hint():
		if platform_brown:
			platform_brown.is_player_on.connect(update_is_player_on_status)
		generate_chain()
		path_length = curve.get_baked_length()

func _process(delta: float) -> void:
	if not Engine.is_editor_hint() and path_follow:
		if path_length <= 0.0:
			path_length = curve.get_baked_length()
			if path_length <= 0.0:
				return
		
		if is_player_on:
			direction = 1
			path_follow.progress += speed * delta * direction
			if path_follow.progress >= path_length:
				path_follow.progress = path_length
			if platform_brown:
				platform_brown.is_device_on = true
		else:
			direction = -1
			path_follow.progress += speed * delta * direction
			if path_follow.progress <= 0.0:
				path_follow.progress = 0.0
			if platform_brown:
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
		
	var chain_path_length = curve.get_baked_length()
	if chain_path_length < link_spacing:
		return
		
	var number_of_links = floor(chain_path_length / link_spacing)
	
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
