extends Node

signal player_died
signal health_changed(current_health: int, max_health: int)
signal inventory_updated(items: Array[CollectableModel])
signal current_game_level
