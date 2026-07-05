extends Node2D
class_name GameContainer

@onready var level_container: Node = $LevelContainer

signal show_bag(show:bool)
signal player_reached_end()

var is_bag_shown := false
var local_bus: GameContainer

func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)
	SceneChanger.register_level_container(level_container)
	
	local_bus = UtilsFuncs.find_local_bus(self)
	if local_bus:
		local_bus.player_reached_end.connect(_placer_won)
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("bag"):
		is_bag_shown = !is_bag_shown
		show_bag.emit(is_bag_shown)

func _on_player_died() -> void:
	print("Main received death signal! Showing Game Over screen...")
	SceneChanger.switch_level("res://common/scenes/game_over/game_over.tscn")
	
func _placer_won() -> void:
	print('won')
