extends Node2D

@export var player_scene: PackedScene
@export var spawn_points: Array[Marker2D]
@onready var players_container: Node2D = $Players/PlayersContainer

var next_spawn_point_index:int = 0

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
	var player_instance = player_scene.instantiate()
	player_instance.position = get_spawn_point()
	player_instance.name = str(id)
	players_container.add_child(player_instance)

func delete_player(id)->void:
	var player_node = players_container.get_node_or_null(str(id))
	if player_node == null:
		return
	player_node.queue_free()

func _on_server_disconnected() -> void:
	for child in players_container.get_children():
		child.queue_free()

func get_spawn_point() -> Vector2:
	if spawn_points.is_empty():
		return Vector2.ZERO
	
	var point_index = next_spawn_point_index
	var point = spawn_points[point_index].position
	next_spawn_point_index = (point_index + 1) % spawn_points.size()
	return point
