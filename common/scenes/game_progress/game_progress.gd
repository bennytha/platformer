# GameOverUI.gd
extends Control

@onready var xp_bar: ProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/XpBar
@onready var xp_count: Label = $MarginContainer/HBoxContainer/VBoxContainer/XpCount
@onready var level_label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/LevelLabel

var current_stat: Dictionary ={}
func _ready():
	set_current_stat()
	# Connect to autoload signals
	ProfileManager.xp_gained.connect(_on_xp_gained)
	ProfileManager.level_up.connect(_on_level_up)

func _on_xp_gained(_amount, current, needed):
	print('xp:',_amount, current, needed)
	xp_bar.max_value = needed + current
	xp_bar.value = current
	xp_count.text = str(current) + 'xp'

func _on_level_up(new_level):
	print('new level:',new_level)
	level_label.text =  str(new_level)
	# Play level-up animation or sound effect here

func set_current_stat():
	current_stat = ProfileManager.get_current_stats()
	#if current_stat
	level_label.text = str(current_stat.level)
	xp_bar.max_value = current_stat.xp + current_stat.xp_needed
	xp_bar.value = current_stat.xp
	xp_count.text = str(current_stat.xp) + 'xp'
