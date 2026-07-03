# SceneUtils.gd
class_name UtilsFuncs
extends RefCounted

## Finds the closest ancestor node of a specific type
static func find_local_bus(from_node: Node) -> GameContainer:
	#var parent = from_node.get_parent()
	#while parent != null:
		#if parent is GameContainer:
			#return parent
		#parent = parent.get_parent()
	var buses = from_node.get_tree().get_nodes_in_group("game_container")
	if not buses.is_empty():
		return buses[0] as GameContainer
	return null
