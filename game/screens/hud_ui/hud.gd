extends Control
@onready var touch_screen_ui: Control = $TouchScreenUI
@onready var keyboard_ui: Control = $KeyboardUI
@onready var xbox_controller_ui: Control = $XboxControllerUI
@onready var label: Label = $Label
@onready var bag: Control = $Bag

# Inside any enemy, trap, or UI element script
var local_bus: GameContainer

func _ready() -> void:
	local_bus = UtilsFuncs.find_local_bus(self)
	
	if local_bus:
		local_bus.show_bag.connect(toggle_bag)
	else:
		print('could not find local_bus')
	if EventBus.current_game and EventBus.current_game.level_name:
		label.text = EventBus.current_game.level_name
		
		
	InputManager.device_changed.connect(_on_device_changed)
	update_hint(InputManager.current_device)

func toggle_bag(value:bool):
	bag.visible = value
	
func _on_device_changed(new_device: InputManager.DeviceType) -> void:
	update_hint(new_device)

func update_hint(device: InputManager.DeviceType) -> void:
	touch_screen_ui.visible = false
	keyboard_ui.visible = false
	xbox_controller_ui.visible = false
	
	if device == InputManager.DeviceType.TOUCH:
		touch_screen_ui.visible = true
	elif device == InputManager.DeviceType.XBOX_CONTROLLER:
		xbox_controller_ui.visible = true
	elif device == InputManager.DeviceType.KEYBOARD_MOUSE:
		keyboard_ui.visible = true

func _on_pause_menu_pressed() -> void:
	local_bus.show_menu.emit(true)
