extends Node2D
@onready var title: Label = $CanvasLayer/VBoxContainer/Title
@onready var quote: Label = $CanvasLayer/VBoxContainer/Quote

@onready var lost: HBoxContainer = $CanvasLayer/MarginContainer/Lost
@onready var won: HBoxContainer = $CanvasLayer/MarginContainer/Won

@onready var retry: Button = $CanvasLayer/MarginContainer/Lost/Retry
@onready var next: Button = $CanvasLayer/MarginContainer/Won/Next
@onready var home: Button = $CanvasLayer/MarginContainer/Won/Home

@export_file("*.tscn") var start_screen_path: String = "res://game/screens/start_screen/start_screen.tscn"
@export_file("*.tscn") var levels_screen_path: String = "res://game/screens/level_selection/stage_select_menu.tscn"
@export_file("*.tscn") var game_container_path: String = "res://game/screens/game_conatiner/game_container.tscn"

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

var next_level:LevelModel

func _ready() -> void:
	if EventBus.game_won:
		next_level = LevelManager.get_next_level(EventBus.current_game.level_id)
		if next_level:
			next.grab_focus()
		else:
			next.hide()
			home.grab_focus()
			
		won.show()
		title.text = 'Victory!'
		quote.text = victory_quotes[randi() % victory_quotes.size()]
	else:
		lost.show()
		retry.grab_focus()
		title.text = 'Wasted!'
		quote.text = defeat_quotes[randi() % defeat_quotes.size()]
		

func _on_home_pressed() -> void:
	SceneChanger.change_scene(start_screen_path)


func _on_retry_pressed() -> void:
	SceneChanger.change_scene(game_container_path)


func _on_levels_pressed() -> void:
	SceneChanger.change_scene(levels_screen_path)


func _on_next_pressed() -> void:
	EventBus.current_game = next_level
	SceneChanger.change_scene(game_container_path)
