# SceneUtils.gd
class_name UtilsFuncs
extends RefCounted

## Finds the closest ancestor node of a specific type
static func find_local_bus(from_node: Node) -> GameContainer:
	var buses = from_node.get_tree().get_nodes_in_group("game_container")
	if not buses.is_empty():
		return buses[0] as GameContainer
	return null

static func is_multiplayer(from_node: Node) -> bool:
	# Treat the game as multiplayer only when a real network peer is active.
	if from_node == null:
		return false

	var multiplayer_api: MultiplayerAPI = from_node.get_multiplayer()
	if multiplayer_api == null or multiplayer_api.multiplayer_peer == null:
		return false

	var peer = multiplayer_api.multiplayer_peer
	return peer is ENetMultiplayerPeer and \
		   peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED
