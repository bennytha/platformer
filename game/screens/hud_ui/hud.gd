extends Control
@onready var touch_screen_ui: Control = $TouchScreenUI
@onready var keyboard_ui: Control = $KeyboardUI
@onready var xbox_controller_ui: Control = $XboxControllerUI
@onready var label: Label = $Label
@onready var timer: Label = $Timer
@onready var bag: Control = $Bag

# elapsed timer (seconds)
var elapsed_time: float = 0.0
var timer_running: bool = false

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

	# start elapsed timer
	elapsed_time = 0.0
	timer_running = true
	timer.text = str(int(elapsed_time))

func _process(delta: float) -> void:
	if timer_running:
		elapsed_time += delta
		# show as MM:SS
		timer.text = format_time(elapsed_time)

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

func format_time(seconds: float) -> String:
	var total := int(seconds)
	var mins := int (total / 60.0)
	var secs := total % 60
	var mins_str := str(mins)
	var secs_str := str(secs)
	if mins < 10:
		mins_str = "0" + mins_str
	if secs < 10:
		secs_str = "0" + secs_str
	return mins_str + ":" + secs_str

func _on_pause_menu_pressed() -> void:
	local_bus.show_menu.emit(true)
