extends Control

@onready var bag: Control = $Bag

# Inside any enemy, trap, or UI element script
var local_bus: GameContainer

func _ready() -> void:
	local_bus = UtilsFuncs.find_local_bus(self)
	
	if local_bus:
		local_bus.show_bag.connect(toggle_bag)
	else:
		print('could not find local_bus')
		
func toggle_bag(value:bool):
	bag.visible = value
