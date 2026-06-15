extends Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var wind_collision_shape_2d: CollisionShape2D = $WindBox/CollisionShape2D
@onready var wind_box: Area2D = $WindBox
@onready var hitBox_collision_shape_2d: CollisionShape2D = $HitBox/CollisionShape2D

@export var wind_force: Vector2 = Vector2(-150, 0)
@export var is_fan_on: bool = true:
	set(value):
		is_fan_on = value
		if is_inside_tree():
			_update_fan_state()
			
@export var on_duration: float = 5.0

func _ready() -> void:
	_update_fan_state()
	if "wind_force" in wind_box:
		wind_box.wind_force = wind_force


func _update_fan_state() -> void:
	animated_sprite_2d.play("on" if is_fan_on else "idle")
	if is_fan_on:
		wind_collision_shape_2d.disabled = false
		hitBox_collision_shape_2d.disabled = false
	else:
		wind_collision_shape_2d.disabled = true
		hitBox_collision_shape_2d.disabled = true
