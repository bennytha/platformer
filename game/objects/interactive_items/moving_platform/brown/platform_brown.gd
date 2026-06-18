extends StaticBody2D
class_name PlatformBrown

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_box: Area2D = $DetectionBox

signal is_player_on(value:bool)

var is_device_on:bool= false

func _ready() -> void:
	detection_box.body_entered.connect(_on_detection_body_entered)
	detection_box.body_exited.connect(_on_detection_body_exited)
	
func _process(_delta: float) -> void:
	if(is_device_on):
		animated_sprite_2d.play("on")
	else:
		animated_sprite_2d.play("default")

func _on_detection_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		is_player_on.emit(true)

func _on_detection_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		is_player_on.emit(false)
