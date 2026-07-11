extends Node2D

@export var is_open:bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

func activate(state:bool):
	if not multiplayer.is_server():
		return
	is_open = state
	set_door_properties()
	
func set_door_properties():
	if is_open:
		animated_sprite_2d.play("open")
		await animated_sprite_2d.animation_finished
		collision_shape_2d.set_deferred('disabled',is_open)
	else:
		animated_sprite_2d.play("default")


func _on_multiplayer_synchronizer_delta_synchronized() -> void:
	set_door_properties()


func _on_pressure_plate_toggle(value: bool) -> void:
	pass # Replace with function body.
