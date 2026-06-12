class_name HealthComponent
extends Node

# Signals to notify other parts of the game (like a UI health bar)
signal health_changed(current_health: int, max_health: int)
signal died

@export var max_health: int = 3
@onready var current_health: int = max_health

func _ready() -> void:
	# Emit initial health values on startup
	health_changed.emit(current_health, max_health)

func damage(amount: int) -> void:
	if current_health <= 0:
		return
		
	current_health -= amount
	# Prevent health from dropping below zero
	current_health = max(current_health, 0) 
	
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		died.emit()
