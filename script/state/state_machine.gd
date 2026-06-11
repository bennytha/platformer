class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func init(player: CharacterBody2D, velocity_comp: VelocityComponent, input_comp: InputComponent) -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.player = player
			child.velocity_comp = velocity_comp
			child.input_comp = input_comp
			child.transitioned.connect(on_child_transitioned)
			
	if initial_state:
		current_state = initial_state
		current_state.enter()

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func on_child_transitioned(new_state_name: String) -> void:
	var new_state: State = states.get(new_state_name.to_lower())
	if !new_state or new_state == current_state:
		return
		
	current_state.exit()
	current_state = new_state
	current_state.enter()
