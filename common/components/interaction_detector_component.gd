class_name InteractionDetectorComponent
extends Area2D

# Tracks the current interactive object the player is overlapping
var current_interactable: Node2D = null

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(_delta: float) -> void:
	# If near something and player presses the interact key
	if current_interactable and Input.is_action_just_pressed("interact"):
		if current_interactable.has_method("interact"):
			current_interactable.interact(get_parent()) # Pass player reference

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		current_interactable = area
		if area.has_method("show_prompt"):
			area.show_prompt(get_parent())

func _on_area_exited(area: Area2D) -> void:
	if area == current_interactable:
		if area.has_method("hide_prompt"):
			area.hide_prompt()
		current_interactable = null
