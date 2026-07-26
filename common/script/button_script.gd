extends Button
const BLIP = preload("uid://d3rlowtnrn80")

func _ready() -> void:
	focus_entered.connect(func(): AudioManager.play_ui_sfx(BLIP))
