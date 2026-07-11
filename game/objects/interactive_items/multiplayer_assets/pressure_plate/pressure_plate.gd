extends Node2D

signal toggle(value:bool)
@onready var up: Sprite2D = $Up
@onready var down: Sprite2D = $Down

@export var is_down:bool = false
var bodies_on_plate = 0

func _on_interaction_body_entered(_body: Node2D) -> void:
	if not multiplayer.is_server():
		return
	bodies_on_plate += 1
	update_plate_state()


func _on_interaction_body_exited(_body: Node2D) -> void:
	if not multiplayer.is_server():
		return
	bodies_on_plate -= 1
	update_plate_state()
		
func update_plate_state():
	is_down = bodies_on_plate > 0
	toggle.emit(is_down)
	set_plate_state()
	
func set_plate_state():
	up.visible = !is_down
	down.visible = is_down

func _on_multiplayer_synchronizer_delta_synchronized() -> void:
	set_plate_state()
