extends Node2D

@onready var chest_open: Sprite2D = $ChestOpen
@onready var chest_closed: Sprite2D = $ChestClosed
@onready var key_spawn: Node2D = $KeySpawn
const KEY = preload("uid://d0wd2412307st")
@export var is_opened:bool = false

func set_chest_property():
	chest_closed.visible = !is_opened
	chest_open.visible = is_opened

func _on_interactable_interacted():
	if not is_opened:
		is_opened = true
		var key_scene = KEY.instantiate()
		key_spawn.add_child(key_scene)
		set_chest_property()

func _on_multiplayer_synchronizer_delta_synchronized() -> void:
	set_chest_property()
