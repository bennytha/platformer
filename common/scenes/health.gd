extends Control

@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect
@onready var h_box_container: HBoxContainer = $HBoxContainer

@export var max_health: int = 3


func _ready() -> void:
	build_hearts()


func build_hearts() -> void:
	for child in h_box_container.get_children().duplicate():
		child.queue_free()

	for index in range(max_health):
		add_heart()


func add_heart() -> void:
	var heart := TextureRect.new()

	if texture_rect and is_instance_valid(texture_rect):
		heart.custom_minimum_size = texture_rect.custom_minimum_size
		heart.texture = texture_rect.texture
		heart.stretch_mode = texture_rect.stretch_mode
		#heart.size = texture_rect.size
		#heart.size_flags_horizontal = texture_rect.size_flags_horizontal
		#heart.size_flags_vertical = texture_rect.size_flags_vertical
		#heart.expand_mode = texture_rect.expand_mode

	h_box_container.add_child(heart)


func remove_heart() -> void:
	var children := h_box_container.get_children()
	if children.is_empty():
		return

	children[-1].queue_free()
