extends Node2D

@export var player_scene: PackedScene
@export var spawn_points: Array[Marker2D]

@onready var players_container: Node2D = $Players/PlayersContainer
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner

var next_spawn_point_index: int = 0

func _enter_tree() -> void:
	# CRITICAL: This must be registered on BOTH server and client 
	# before any network replication data arrives.
	$PlayerSpawner.spawn_function = _spawn_player

func _ready() -> void:
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_disconnected.connect(delete_player)
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	for id in multiplayer.get_peers():
		add_player(id)
	add_player(1)

func _on_peer_connected(id: int) -> void:
	add_player(id)

func add_player(id: int) -> void:
	var spawn_data = {
		"id": id,
		"position": get_spawn_point()
	}
	player_spawner.spawn(spawn_data)

func _spawn_player(data: Variant) -> Node:
	var player_instance = player_scene.instantiate()
	player_instance.name = str(data["id"])
	player_instance.global_position = data["position"]
	return player_instance

func delete_player(id) -> void:
	var player_node = players_container.get_node_or_null(str(id))
	if player_node != null:
		player_node.queue_free()

func _on_server_disconnected() -> void:
	for child in players_container.get_children():
		child.queue_free()

func get_spawn_point() -> Vector2:
	if spawn_points.is_empty():
		return Vector2.ZERO
	var point_index = next_spawn_point_index
	var point = spawn_points[point_index].global_position
	next_spawn_point_index = (point_index + 1) % spawn_points.size()
	return point
