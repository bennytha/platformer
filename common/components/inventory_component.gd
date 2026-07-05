class_name InventoryComponent
extends Node

# Emitted whenever the inventory changes so your UI can update automatically
#signal inventory_updated(items: Array[CollectableModel])

# The actual storage container holding our item resources
@export var items: Array[CollectableModel] = []

func add_item(item: CollectableModel) -> void:
	items.append(item)
	EventBus.inventory_updated.emit(items)

func remove_item(item: CollectableModel) -> bool:
	if items.has(item):
		items.erase(item)
		EventBus.inventory_updated.emit(items)
		return true
	return false

func has_item_by_name(target_name: String) -> bool:
	for item in items:
		if item.item_name.to_lower() == target_name.to_lower():
			return true
	return false
