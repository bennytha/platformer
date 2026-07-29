extends Node2D
@onready var title: Label = $CanvasLayer/VBoxContainer/Title
@onready var quote: Label = $CanvasLayer/VBoxContainer/Quote
@onready var game_stats: VBoxContainer = $CanvasLayer/VBoxContainer/GameStats
@onready var game_progress: Control = $CanvasLayer/GameProgress

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
		game_progress.show()
		_render_stats(EventBus.won_game_metadata)
	else:
		lost.show()
		retry.grab_focus()
		title.text = 'Wasted!'
		quote.text = defeat_quotes[randi() % defeat_quotes.size()]

func _render_stats(stats: Dictionary) -> void:
	stats.erase('completed')
	ProfileManager.save_game()
	_update_player_progress(stats)
	for key in stats.keys():
		var display_key = _format_stat_key(key)
		var value_label = str(stats[key])
		if stats[key] == 0:
			continue
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		if key == 'change':
			if stats[key] != 0:
				if stats[key] > 0:
					display_key = 'Score improved by'
				else:
					display_key = 'Score diminish by'
		var key_label = Label.new()
		key_label.text = display_key
		key_label.custom_minimum_size = Vector2(100,0)
		key_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		key_label.horizontal_alignment = 0
		key_label.theme = title.theme
		key_label.add_theme_font_size_override('font_size', 6)

		var value = Label.new()
		var formated_value = ''
		if key == 'time_in_seconds':
			formated_value ='-'+ value_label
		else:
			formated_value = value_label
		value.text = formated_value
		value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value.horizontal_alignment = 2
		value.theme = title.theme
		value.add_theme_font_size_override('font_size', 6)

		var positive_color = Color(0.6, 0.902, 0.6, 0.765)
		var negative_color = Color(0.902, 0.6, 0.6, 0.765)
		var light_color = Color(1.0, 1.0, 1.0, 0.765)
		if key != 'total':
				key_label.modulate = light_color
				value.modulate = light_color
		# Colorize the `change` row: green for positive, red for negative
		if key == 'change':
			var change_val = stats[key]
			if typeof(change_val) == TYPE_STRING:
				change_val = float(str(change_val))
			if change_val > 0:
				# show explicit plus for positive change
				value.text = '+' + value.text
				key_label.modulate = positive_color
				value.modulate = positive_color
			elif change_val < 0:
				key_label.modulate = negative_color
				value.modulate = negative_color
			
		if key == 'time_in_seconds':
			value.modulate = negative_color

		row.add_child(key_label)
		row.add_child(value)
		game_stats.add_child(row)

func _format_stat_key(key: String) -> String:
	return key.capitalize().replace('_', ' ')
	
func _update_player_progress(stats: Dictionary) -> void:
	if not stats:
		return

	if stats.has('change') and stats['change'] > 0:
		ProfileManager.add_end_game_score(stats['change'])
	elif stats.has('total'):
		ProfileManager.add_end_game_score(stats['total'])

func _on_home_pressed() -> void:
	SceneChanger.change_scene(start_screen_path)


func _on_retry_pressed() -> void:
	SceneChanger.change_scene(game_container_path)


func _on_levels_pressed() -> void:
	SceneChanger.change_scene(levels_screen_path)


func _on_next_pressed() -> void:
	EventBus.current_game = next_level
	SceneChanger.change_scene(game_container_path)
