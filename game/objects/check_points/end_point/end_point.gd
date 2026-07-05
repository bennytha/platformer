extends Node2D
var local_bus: GameContainer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	local_bus = UtilsFuncs.find_local_bus(self)

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group('player'):
		animated_sprite_2d.play('moving')
		await get_tree().create_timer(2.0).timeout
		if local_bus:
			local_bus.player_reached_end.emit()
