extends Control
@onready var touch_screen_ui: Control = $TouchScreenUI
@onready var keyboard_ui: Control = $KeyboardUI

@onready var bag: Control = $Bag

# Inside any enemy, trap, or UI element script
var local_bus: GameContainer

func _ready() -> void:
	local_bus = UtilsFuncs.find_local_bus(self)
	
	if local_bus:
		local_bus.show_bag.connect(toggle_bag)
	else:
		print('could not find local_bus')
		
	InputManager.device_changed.connect(_on_device_changed)
	update_hint(InputManager.current_device)

func toggle_bag(value:bool):
	bag.visible = value

func _on_device_changed(new_device: InputManager.DeviceType) -> void:
	update_hint(new_device)

func update_hint(device: InputManager.DeviceType) -> void:
	if device == InputManager.DeviceType.TOUCH:
		touch_screen_ui.visible = true
		keyboard_ui.visible = false
	else:
		touch_screen_ui.visible = false
		keyboard_ui.visible = true
