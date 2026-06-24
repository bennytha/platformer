class_name InventoryComponent
extends Node

# Emitted whenever the inventory changes so your UI can update automatically
signal inventory_updated(items: Array[ItemData])

# The actual storage container holding our item resources
@export var items: Array[ItemData] = []

func add_item(item: ItemData) -> void:
	items.append(item)
	inventory_updated.emit(items)
	print("Collected: ", item.item_name, " | Total Items: ", items.size())

func remove_item(item: ItemData) -> bool:
	if items.has(item):
		items.erase(item)
		inventory_updated.emit(items)
		return true
	return false

func has_item_by_name(target_name: String) -> bool:
	for item in items:
		if item.item_name.to_lower() == target_name.to_lower():
			return true
	return false
