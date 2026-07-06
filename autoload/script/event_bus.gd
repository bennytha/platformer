extends Node

signal player_died
signal health_changed(current_health: int, max_health: int)
signal inventory_updated(items: Array[CollectableModel])

var current_game_level_path: String = ""
var current_game: LevelModel
