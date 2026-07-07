extends Node2D
@onready var title: Label = $CanvasLayer/VBoxContainer/Title
@onready var quote: Label = $CanvasLayer/VBoxContainer/Quote

const defeat_quotes :Array[String] = [
	'Death is not the end of the journey, merely the cost of tuition.',
	'Your legend ends here... until the next coin drops.',
	'Critical error. Vital signs terminated. Re-initializing sequence...',
	'Well, that could have gone better. Lets pretend nobody saw that.',
	'The shadows claim another brave soul. Rest now, before the loop begins anew.',
	'CRITICAL ERROR: Player skill not found. Try again?',
	'Continue? 9... 8... 7... Dont let the high score slip away!',
	'Wasted! Thats gonna leave a pixelated bruise.'
]

const victory_quotes: Array[String] = [
	'The stars align, the dust settles, and your name is etched into history.',
	'Flawless execution. They ll be writing songs about this one.',
	'Objective secured. Perfection achieved.',
	'Against all odds, you stood tall. The night is yours.',
	'GG. You made that look entirely too easy.',
	'STAGE CLEAR! You made that look like a pre-recorded demo.',
	'No words!'
]

func _ready() -> void:
	if EventBus.game_won:
		title.text = 'Victory!'
		quote.text = victory_quotes[randi() % victory_quotes.size()]
	else:
		title.text = 'Wasted!'
		quote.text = defeat_quotes[randi() % defeat_quotes.size()]
		

func _on_home_pressed() -> void:
	SceneChanger.change_scene("res://game/screens/start_screen/start_screen.tscn")
