extends Node

# Signals
signal player_died
signal health_changed(current_health: int, max_health: int)
signal inventory_updated(items: Array[CollectableModel])

# Variables
var current_game: LevelModel
var game_won:bool= false
