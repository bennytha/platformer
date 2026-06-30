class_name HealthComponent
extends Node

signal died

@export var max_health: int = 3
var current_health: int = max_health

func _ready() -> void:
	EventBus.health_changed.emit(current_health, max_health)

func damage(amount: int) -> void:
	var new_health: int = int(clamp(current_health - amount, 0, max_health))
	if new_health == current_health:
		return

	current_health = new_health
	EventBus.health_changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()

func heal(amount: int) -> void:
	var new_health: int = int(clamp(current_health + amount, 0, max_health))
	if new_health == current_health:
		return

	current_health = new_health
	EventBus.health_changed.emit(current_health, max_health)
