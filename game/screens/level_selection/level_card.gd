class_name LevelCard
extends Button

var level_data: LevelModel
var is_unlocked: bool = false
var is_completed: bool = false
var touch_dragged := false

signal stage_selected(level_data: LevelModel)
const BLIP = preload("uid://d3rlowtnrn80")

@onready var level_name: Label = $MarginContainer/VBoxContainer/Name
@onready var highscore_value: Label = $MarginContainer/VBoxContainer/VBoxContainer/HighscoreValue
@onready var locked: TextureRect = $MarginContainer/HBoxContainer/Locked
@onready var completed: TextureRect = $MarginContainer/HBoxContainer/Completed


func _ready() -> void:
	focus_entered.connect(func(): AudioManager.play_sfx(BLIP))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_dragged = false
		elif touch_dragged:
			accept_event()
	elif event is InputEventScreenDrag:
		touch_dragged = true
		accept_event()

func setup(data: LevelModel, is_unlocked_flag: bool, is_completed_flag: bool, highscore:int=0):
	level_data = data
	is_unlocked = is_unlocked_flag
	is_completed = is_completed_flag
	level_name.text = data.level_name
	
	# Visual feedback based on save state
	disabled = not is_unlocked
	
	if is_completed:
		completed.show()
	
	if not is_unlocked:
		locked.show()
		
	if highscore:
		highscore_value.text = str(highscore)
		

func _pressed():
	if touch_dragged:
		touch_dragged = false
		return
	stage_selected.emit(level_data)
