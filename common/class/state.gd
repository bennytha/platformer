class_name State
extends Node
@warning_ignore("unused_signal")
signal transitioned(state_name: String)

# References initialized by the StateMachine
var player: CharacterBody2D
var velocity_comp: VelocityComponent
var input_comp: InputComponent
var sprite: AnimatedSprite2D

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
