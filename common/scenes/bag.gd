extends Control
@onready var grid_container: GridContainer = $PanelContainer/VBoxContainer/GridContainer
const INVENTORY_ITEM = preload("uid://6emrpxbhgaqf")
@onready var empty: Label = $PanelContainer/VBoxContainer/Empty

var grouped_items: Array[Dictionary] = []

func _ready() -> void:
	EventBus.inventory_updated.connect(on_inventry_updated)

func on_inventry_updated(items: Array[CollectableModel]) -> void:
	grouped_items.clear()

	var counts_by_name: Dictionary = {}
	for item in items:
		if item == null:
			continue

		var item_name: String = item.item_name
		if counts_by_name.has(item_name):
			counts_by_name[item_name] += 1
		else:
			counts_by_name[item_name] = 1

	for item_name in counts_by_name.keys():
		var grouped_item: Dictionary = {
			"item_name": item_name,
			"count": counts_by_name[item_name]
		}

		for item in items:
			if item != null and item.item_name == item_name:
				grouped_item["thumbnail"] = item.thumbnail
				grouped_item["is_consumable"] = item.is_consumable
				break

		grouped_items.append(grouped_item)

	update_grid()

func update_grid() -> void:
	for child in grid_container.get_children():
		child.queue_free()

	empty.visible = grouped_items.is_empty()
	grid_container.visible = not grouped_items.is_empty()

	for grouped_item in grouped_items:
		var inventory_item: PanelContainer = INVENTORY_ITEM.instantiate()
		var texture_rect: TextureRect = inventory_item.get_node("TextureRect")
		var count_label: Label = inventory_item.get_node("Label")

		texture_rect.texture = grouped_item.get("thumbnail")
		count_label.text = str(grouped_item.get("count", 0))

		grid_container.add_child(inventory_item)
