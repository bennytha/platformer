# GameOverUI.gd
extends Control
const LEVEL_UP_AUDIO = preload("uid://sniig4qx8ts3")

@onready var xp_bar: ProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/XpBar
@onready var xp_count: Label = $MarginContainer/HBoxContainer/VBoxContainer/XpCount
@onready var level_label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/LevelLabel

var current_stat: Dictionary = {}
var xp_tween: Tween

func _ready():
	set_current_stat()
	# Connect to autoload signals
	ProfileManager.xp_gained.connect(_on_xp_gained)
	ProfileManager.level_up.connect(_on_level_up)

func _on_xp_gained(_amount, current, needed):
	_animate_xp_bar(current, needed + current)
	xp_count.text = str(current) + 'xp'

func _on_level_up(new_level):
	level_label.text = str(new_level)
	# Play level-up animation or sound effect here
	AudioManager.play_ui_sfx(LEVEL_UP_AUDIO)

func set_current_stat():
	current_stat = ProfileManager.get_current_stats()
	level_label.text = str(current_stat.level)
	_animate_xp_bar(current_stat.xp, current_stat.xp + current_stat.xp_needed)
	xp_count.text = str(current_stat.xp) + 'xp'

func _animate_xp_bar(new_value: int, new_max_value: int) -> void:
	if xp_tween:
		xp_tween.kill()

	var start_value = xp_bar.value
	xp_bar.max_value = new_max_value
	xp_tween = create_tween()
	xp_tween.tween_property(xp_bar, "value", new_value, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if new_value < start_value:
		xp_bar.value = new_value
