extends Control

@onready var h_box_container: HBoxContainer = $HBoxContainer
const HEART_TEXTURE = preload("uid://chg4f4sklyuws")
const CUSTOM_MINIMUM_SIZE = Vector2(16,0)
const STRETCH_MODE = TextureRect.STRETCH_KEEP_ASPECT

var health: int = 0

func _ready() -> void:
	EventBus.health_changed.connect(update_hearts)

func update_hearts(current_health:int, _max_health:int) -> void:
	var visible_hearts := h_box_container.get_child_count()
	if health == current_health and visible_hearts == current_health:
		return

	health = current_health

	if visible_hearts < current_health:
		for _i in range(current_health - visible_hearts):
			add_heart()
	elif visible_hearts > current_health:
		while h_box_container.get_child_count() > current_health:
			var heart_to_remove := h_box_container.get_child(h_box_container.get_child_count() - 1)
			h_box_container.remove_child(heart_to_remove)
			heart_to_remove.queue_free()

func add_heart() -> void:
	var heart := TextureRect.new()
	heart.texture = HEART_TEXTURE
	heart.stretch_mode = STRETCH_MODE
	heart.custom_minimum_size = CUSTOM_MINIMUM_SIZE

	h_box_container.add_child(heart)
