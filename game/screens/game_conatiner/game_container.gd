extends Node2D
class_name GameContainer

@export_file("*.tscn") var game_over_scene_path: String = "res://game/screens/game_over/game_over.tscn"
@onready var level_container: Node = $LevelContainer
@onready var player: CharacterBody2D = $Player/Player
@onready var pause_menu: Control = $UI/PauseMenu
@onready var hud: Control = $UI/MarginContainer/HUD

signal show_bag(show:bool)
signal show_menu(show:bool)
signal player_reached_end()

var is_menu_shown := false
var is_bag_shown := false
var local_bus: GameContainer

func _ready() -> void:
	show_menu.connect(toggle_menu)
	EventBus.player_died.connect(_on_player_died)
	SceneChanger.register_level_container(level_container)
	
	load_level()
	
	local_bus = UtilsFuncs.find_local_bus(self)
	if local_bus:
		local_bus.player_reached_end.connect(_placer_won)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("bag"):
		is_bag_shown = !is_bag_shown
		show_bag.emit(is_bag_shown)
		
	if Input.is_action_just_pressed("pause_menu"):
		is_menu_shown =!is_menu_shown
		player.set_player_input_enabled(!is_menu_shown)
		show_menu.emit(is_menu_shown)
		
func toggle_menu(value:bool) -> void:
	is_menu_shown = value
	player.set_player_input_enabled(!is_menu_shown)
	pause_menu.visible = is_menu_shown
		
func load_level() -> void:
	# Load initial level if available
	if EventBus.current_game and EventBus.current_game.scene_path:
		# Remove existing children
		for child in level_container.get_children():
			child.queue_free()
		
		# Load and instantiate the scene
		var level_scene = load(EventBus.current_game.scene_path)
		if level_scene:
			var level_instance = level_scene.instantiate()
			level_container.add_child(level_instance)
			
			#making player aware of special terrain
			var special_terrain_container: Node = null
			for child in level_instance.get_children():
				if child.name == "SpecialLand" and child.is_in_group("special_terrain"):
					special_terrain_container = child
					break
			
			if special_terrain_container and special_terrain_container is TileMapLayer and player:
				player.level_tilemap = special_terrain_container
				
				var surface_detector = player.get_node_or_null("SurfaceDetectorComponent")
				if surface_detector and surface_detector.has_method("_ready"):
					surface_detector._ready()
			
			# Check for player start point in group
			var player_start_point = null
			for child in level_instance.get_children():
				if child.is_in_group("player_start_point"):
					player_start_point = child
					break
			
			# Check if it's a Marker2D and get position
			if player_start_point and player_start_point.marker_2d is Marker2D:
				var start_position = player_start_point.marker_2d.global_position
				player.global_position = start_position
				
func _on_player_died() -> void:
	EventBus.game_won = false
	SceneChanger.switch_level(game_over_scene_path)
	
func _placer_won() -> void:
	EventBus.game_won = true
	var data = set_won_game_stats()
	EventBus.won_game_metadata = data
	LevelManager.complete_level(EventBus.current_game.level_id,data)
	SceneChanger.switch_level(game_over_scene_path)


func set_won_game_stats() :
	var previous_score = LevelManager.get_meta_data(EventBus.current_game.level_id)
	var current_score :Dictionary[String, int] = {
		"lives": int(player.health_component.current_health * 1000),
		"collectables": int(player.inventory_component.items.size() * 100),
		"time_in_seconds": int(hud.elapsed_time) * 10,
		"total": 0,
	}
	current_score["total"] = current_score["lives"] + current_score["collectables"] - current_score["time_in_seconds"]
	var updated_stats = {}
	# If both previous and current scores are dictionaries, compute change in `total`
	if typeof(previous_score) == TYPE_DICTIONARY and typeof(current_score) == TYPE_DICTIONARY:
		var prev_total = previous_score.get("total", 0)
		var curr_total = current_score.get("total", 0)
		var change = curr_total - prev_total
		if curr_total != change:
			current_score["change"] = change
		updated_stats = current_score.duplicate()
	elif typeof(current_score) == TYPE_DICTIONARY:
		# No previous data, but current exists — just use current
		updated_stats = current_score.duplicate()
	else:
		updated_stats = {}

	return updated_stats
