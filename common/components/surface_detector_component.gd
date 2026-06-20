class_name SurfaceDetectorComponent
extends Node

@export var tilemap_layer: TileMapLayer
@export var velocity_component: VelocityComponent
@export var player: CharacterBody2D

var current_surface: String = "normal"

func _physics_process(_delta: float) -> void:
	if not tilemap_layer or not velocity_component or not player:
		return
		
	if player.is_on_floor():
		# 1. Find the tile coordinates directly beneath the player's center feet
		# We shift down by a few pixels (e.g., 4 to 8) to ensure we hit the tile geometry
		var player_feet_position: Vector2 = player.global_position + Vector2(0, 4)
		var tile_coords: Vector2i = tilemap_layer.local_to_map(player_feet_position)
		
		# 2. Extract tile metadata data safely
		var tile_data: TileData = tilemap_layer.get_cell_tile_data(tile_coords)
		
		if tile_data:
			var surface = tile_data.get_custom_data("surface_type")
			if surface != current_surface:
				current_surface = surface
				apply_surface_physics(surface)
		else:
			_reset_to_normal()
	else:
		# If the player is airborne, preserve their modified physics until they land, 
		# OR reset immediately depending on your design choice.
		if current_surface != "normal":
			_reset_to_normal()

func apply_surface_physics(surface: String) -> void:
	match surface:
		"ice":
			velocity_component.speed = velocity_component.base_speed
			velocity_component.acceleration = 150.0
			velocity_component.friction = 100.0
			velocity_component.can_move = true
		"sand":
			velocity_component.speed = velocity_component.base_speed * 0.5
			velocity_component.acceleration = velocity_component.base_acceleration
			velocity_component.friction = velocity_component.base_friction * 2.0
			velocity_component.can_move = true
		"mud":
			velocity_component.can_move = false
		_:
			_reset_to_normal()

func _reset_to_normal() -> void:
	current_surface = "normal"
	velocity_component.reset_to_normal()
