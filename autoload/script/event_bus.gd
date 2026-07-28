extends Node

# Signals
@warning_ignore("unused_signal")
signal player_died
@warning_ignore("unused_signal")
signal health_changed(current_health: int, max_health: int)
@warning_ignore("unused_signal")
signal inventory_updated(items: Array[CollectableModel])

# Variables
var current_game: LevelModel
var game_won: bool = false
var won_game_metadata: Dictionary[String, int] = {
	"lives": 0,
	"collectables": 0,
	"time_in_seconds": 0,
	"total":0,
	"change":0
}
