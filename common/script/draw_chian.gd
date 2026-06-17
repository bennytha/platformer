extends Path2D

# Drag and drop your Chain Link scene or a PackedScene with just a Sprite2D here
@export var chain_link_scene: PackedScene 
# How many pixels apart each chain link should be (match your sprite's width/height)
@export var link_spacing: float = 16.0 

func _ready() -> void:
	generate_chain()

func generate_chain() -> void:
	if not chain_link_scene:
		push_warning("Forgot to assign the chain link scene!")
		return
		
	var path_length = curve.get_baked_length()
	# Calculate how many links fit on this path
	var number_of_links = floor(path_length / link_spacing)
	
	for i in range(number_of_links):
		# Find the pixel distance along the path for this specific link
		var current_distance = i * link_spacing
		
		# Get the exact X, Y coordinates and the rotation angle at this distance
		var link_pos: Vector2 = curve.sample_baked(current_distance)
		# We sample slightly ahead to figure out which direction the link should face
		var next_pos: Vector2 = curve.sample_baked(current_distance + 1.0)
		var link_angle: float = (next_pos - link_pos).angle()
		
		# Instantiate the link
		var link = chain_link_scene.instantiate() as Node2D
		add_child(link)
		
		# Position and rotate it
		link.position = link_pos
		link.rotation = link_angle
