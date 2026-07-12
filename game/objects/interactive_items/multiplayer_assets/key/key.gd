extends Node2D


@export var follow_offset:Vector2 = Vector2(-50,-60)
@export var lerp_speed:float = 5
var following_body:CharacterBody2D

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	following_body = body

func _process(delta: float) -> void:
	if multiplayer.is_server():
		if following_body != null:
			global_position = lerp(
				following_body.global_position + follow_offset,
				global_position,
				pow(.5,delta*lerp_speed)
			)
