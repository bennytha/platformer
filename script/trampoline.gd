extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Customize how high this specific trampoline shoots the player
@export var bounce_velocity: float = -600.0


func _on_area_entered(area: Area2D) -> void:
	animated_sprite_2d.play("jump")
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("idle")
