class_name InputComponent 
extends Node

#var move_dir : Vector2 = Vector2.ZERO;
#var jump_pressed := false;
#
#func update() -> void:
	#move_dir = Input.get_vector("move_left","move_right","","")
	#jump_pressed = Input.is_action_just_pressed("jump")

var x_axis: float = 0.0

func _process(_delta: float) -> void:
	x_axis = Input.get_axis("move_left", "move_right")

func is_jump_just_pressed() -> bool:
	return Input.is_action_just_pressed("jump")

func is_jump_released() -> bool:
	return Input.is_action_just_released("jump")
